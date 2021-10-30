pipeline {
  environment {
    imageName = "minecraft-bedrock-server"
    dockerhubRegistry = "iceoid/$imageName"
    githubRegistry = "ghcr.io/iceoid/$imageName"
    dockerhubCredentials = 'DOCKERHUB_TOKEN'
    githubCredentials = 'GITHUB_TOKEN'
    
    dockerhubImage = ''
    dockerhubImageLatest = ''
    githubImage = ''
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git branch: 'main', credentialsId: 'GITHUB_TOKEN', url: 'https://github.com/Iceoid/minecraft-bedrock-server.git'
      }
    }
    stage('Building image') {
      steps{
        script {
//           dockerhubImage = docker.build dockerhubRegistry + ":$BUILD_NUMBER"
          dockerhubImageLatest = docker.build(dockerhubRegistry + ":latest") 
          
          githubImage = docker.build(githubRegistry + ":latest")
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( '', dockerhubCredentials ) {
//             dockerhubImage.push()
            dockerhubImageLatest.push()
          }
          docker.withRegistry('https://' + githubRegistry, githubCredentials) {
            githubImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
//         sh "docker rmi $dockerhubRegistry$imageName:$BUILD_NUMBER"
        sh "docker rmi $dockerhubRegistry:latest"
        sh "docker rmi $githubRegistry:latest"
      }
    }
  }
  post {
    failure {
        mail bcc: '', body: "<b>Jenkins Build Report</b><br><br> Project: ${env.JOB_NAME} <br> \
        Build Number: ${env.BUILD_NUMBER} <br> \
        Status: <b>Failed</b> <br> \
        Build URL: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', \
        subject: "Jenkins Build Failed: ${env.JOB_NAME}", to: "alerts@mindlab.dev";  

    }
  }
}
