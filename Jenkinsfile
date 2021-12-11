pipeline {
  environment {
    userName = "hexlo"
    imageName = "minecraft-bedrock-server"
    tag = ":latest"
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
          echo "pwd: $pwd"
          echo "WORKSPACE=${WORKSPACE}"
          echo "$(ls -al $WORKSPACE)"
          serverVersion = sh(script: 'get-latest-version.sh', , returnStdout: true).trim()
          echo "serverVersion=${serverVersion}"
        }
      }
    }
    stage('Building image') {
      steps{

        script {
//           dockerhubImage = docker.build dockerhubRegistry + ":$BUILD_NUMBER"
          dockerhubImageLatest = docker.build( "${dockerhubRegistry}${tag}" )
          if (serverVersion) {
            dockerhubImageVerNum = docker.build( "${dockerhubRegistry}${serverVersion}" )
          }
          githubImage = docker.build( "${githubRegistry}${tag}" )
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( '', "${dockerhubCredentials}" ) {
//             dockerhubImage.push()
            dockerhubImageLatest.push()
            if (serverVersion) {
              dockerhubImageVerNum.push()
            }
          }
          docker.withRegistry("https://${githubRegistry}", "${githubCredentials}" ) {
            githubImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
//         sh "docker rmi $dockerhubRegistry$imageName:$BUILD_NUMBER"
        sh "docker rmi ${dockerhubRegistry}${tag}"
        sh "docker rmi ${dockerhubRegistry}${serverVersion}"
        sh "docker rmi ${githubRegistry}${tag}"
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
