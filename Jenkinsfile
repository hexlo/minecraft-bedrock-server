pipeline {
  environment {
    userName = "hexlo"
    imageName = "minecraft-bedrock-server"
    tag = 'latest'
    gitRepo = "https://github.com/${userName}/${imageName}.git"
    dockerhubRegistry = "${userName}/${imageName}"
    githubRegistry = "ghcr.io/${userName}/${imageName}"
    
    dockerhubCredentials = 'DOCKERHUB_TOKEN'
    githubCredentials = 'GITHUB_TOKEN'
    
    dockerhubImage = ''
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
          if (tag == 'latest') {
            serverVersion = sh(script: "${WORKSPACE}/get-latest-version.sh", , returnStdout: true).trim()
          }
          else {
            serverVersion = tag
          }
          echo "serverVersion=${serverVersion}"
        }
      }
    }
    stage('Building image') {
      steps{
        script {
          date = sh "echo \$(date +%Y-%m-%d:%H:%M:%S)"
          // Docker Hub
          dockerhubImage = docker.build( "${dockerhubRegistry}:${tag}", "--no-cache --build-arg CACHE_DATE=${date} .")
          
          // Github
          githubImage = docker.build( "${githubRegistry}:${tag}", "--no-cache --build-arg CACHE_DATE=${date} .")
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          // Docker Hub
          docker.withRegistry( '', "${dockerhubCredentials}" ) {
            dockerhubImage.push("${tag}") 
            dockerhubImage.push("${serverVersion}")
            // dockerhubImage.push("${BUILD_NUMBER}")
          }
          // Github
          docker.withRegistry("https://${githubRegistry}", "${githubCredentials}" ) {
            githubImage.push("${tag}")
            githubImage.push("${serverVersion}")
            // githubImage.push("${BUILD_NUMBER}")
          }
        }
      }
    }
    stage('Remove Unused docker images') {
      steps{
        sh "docker system prune -f"
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
