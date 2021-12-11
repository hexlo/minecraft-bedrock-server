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
    
    dockerhubImage = ''
    dockerhubImageLatest = ''
    githubImage = ''
    
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
          dockerhubImageLatest = docker.build( "${dockerhubRegistry}:${tag}" )
          dockerhubImageBuildNum = docker.build( "${dockerhubRegistry}:${BUILD_NUMBER}" )
          if (serverVersion) {
            dockerhubImageVerNum = docker.build( "${dockerhubRegistry}:${serverVersion}" )
          }
          
          // Github
          githubImage = docker.build( "${githubRegistry}:${tag}" )
          githubImageBuildNum = docker.build( "${githubRegistry}:${BUILD_NUMBER}" )
          if (serverVersion) {
            githubImageVerNum = docker.build( "${githubRegistry}:${serverVersion}" )
          }
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( '', "${dockerhubCredentials}" ) {
            dockerhubImageLatest.push()
            dockerhubImageBuildNum.push()
            if (dockerhubImageVerNum) {
              dockerhubImageVerNum.push()
            }
          }
          docker.withRegistry("https://${githubRegistry}", "${githubCredentials}" ) {
            githubImage.push()
            githubImageBuildNum.push()
            if (dockerhubImageVerNum) {
              githubImageVerNum.push()
            }
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
//         sh "docker rmi $dockerhubRegistry$imageName:$BUILD_NUMBER"
        sh "docker rmi ${dockerhubRegistry}:${tag}"
        sh "docker rmi ${dockerhubRegistry}:${BUILD_NUMBER}"
        sh "docker rmi ${dockerhubRegistry}:${serverVersion}"
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
