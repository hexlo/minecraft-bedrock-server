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
            sh '''
              serverVersion=$(curl -v -L --silent \
              -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
              https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 \
              | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' \
              | sed 's#.*/bedrock-server-##' | sed 's/.zip//')
            '''
          }
      }
    }
    stage('Building image') {
      steps{

        script {
//           dockerhubImage = docker.build dockerhubRegistry + ":$BUILD_NUMBER"
          dockerhubImageLatest = docker.build( "${dockerhubRegistry}${tag}" )
          if (serverVersion) {
            dockerhubImageVerNum = docker.build( "${dokcerhubRegistry}${serverVersion}" )
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
