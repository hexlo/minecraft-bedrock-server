pipeline {
  environment {
    userName = "hexlo"
    imageName = "minecraft-bedrock-server"
    tag = "latest"
    gitRepo = "https://github.com/${userName}/${imageName}.git"
    dockerhubRegistry = "${userName}/${imageName}"
    githubRegistry = "ghcr.io/${userName}/${imageName}"
    
    dockerhubCredentials = 'DOCKERHUB_TOKEN'
    githubCredentials = 'GITHUB_TOKEN'
    
    serverVersion = ''
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git branch: 'main', credentialsId: "${githubCredentials}", url: "${gitRepo}"
      }
    }
    stage('Getting Latest Version') {
      steps {
        script {
          serverVersion = sh(script: "${WORKSPACE}/get-latest-version.sh", , returnStdout: true).trim()
          echo "serverVersion=${serverVersion}"
        }
      }
    }
    stage('Building image') {
      steps{

        script {
          // Docker Hub
          def dockerhubImage = docker.build( "${dockerhubRegistry}:${tag}" )
          
          // Github
          def githubImage = docker.build( "${githubRegistry}:${tag}" )
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          // Docker Hub
          docker.withRegistry( '', "${dockerhubCredentials}" ) {
            dockerhubImage.push("${tag}")
            dockerhubImage.push("${BUILD_NUMBER}")
            dockerhubImage.push("${serverVersion}")
          }
          // Github
          docker.withRegistry("https://${githubRegistry}", "${githubCredentials}" ) {
            githubImage.push("${tag}")
            githubImage.push("${BUILD_NUMBER}")
            githubImage.push("${serverVersion}")
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        // Docker Hub
        sh "docker rmi ${dockerhubRegistry}:${tag}"
        sh "docker rmi ${dockerhubRegistry}:${BUILD_NUMBER}"
        sh "docker rmi ${dockerhubRegistry}:${serverVersion}"
        
        // Github
        sh "docker rmi ${githubRegistry}:${tag}"
        sh "docker rmi ${githubRegistry}:${BUILD_NUMBER}"
        sh "docker rmi ${githubRegistry}:${serverVersion}"
      }
    }
  }
  post {
    failure {
        mail bcc: '', body: "<b>Jenkins Build Report</b><br><br> Project: ${env.JOB_NAME} <br> \
        Build Number: ${env.BUILD_NUMBER} <br> \
        Status: <b>Failed</b> <br> \
        Build URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', \
        subject: "Jenkins Build Failed: ${env.JOB_NAME}", to: "jenkins@mindlab.dev";  
    }
  }
}
