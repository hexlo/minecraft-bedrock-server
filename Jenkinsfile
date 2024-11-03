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
    jenkins_email = credentials('RUNX_EMAIL')
    
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
            serverVersion = sh(script: "${WORKSPACE}/.scripts/get-latest-version.sh", , returnStdout: true).trim()
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
          // Docker Hub
          dockerhubImage = docker.build( "${dockerhubRegistry}:${tag}", "--no-cache .")
          
          // Github
          githubImage = docker.build( "${githubRegistry}:${tag}", "--no-cache .")
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
          }
          // Github
          docker.withRegistry("https://${githubRegistry}", "${githubCredentials}" ) {
            githubImage.push("${tag}")
            githubImage.push("${serverVersion}")
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
    always {
        mail bcc: '', body: "<b>Jenkins Build Report</b><br><br> Project: ${env.JOB_NAME} <br> \
        Build Number: ${env.BUILD_NUMBER} <br> \
        Status: <b>Failed</b> <br> \
        Build URL: ${env.BUILD_URL}, cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', \
        subject: "Jenkins Build Failed: ${env.JOB_NAME}", to: ${jenkins_email};  
    }
  }
}
