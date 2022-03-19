pipeline {
  environment {
    userName = "hexlo"
    imageName = "minecraft-bedrock-server"
    // Set buildVersion to manually change the server version. Leave empty for defaulting to 'latest'
    buildVersion = ''
    tag = buildVersion ? buildVersion : 'latest'
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
          if (tag == 'latest') {
            serverVersion = sh(script: "${WORKSPACE}/get-latest-version.sh", , returnStdout: true).trim()
          }
          else {
            serverVersion = buildVersion
          }
          echo "serverVersion=${serverVersion}"
        }
      }
    }
    stage('Building image') {
      steps{
        script {
          def date = sh "date +%Y-%m-%d:%H:%M:%S"
          // Docker Hub
          def dockerhubImage = docker.build( "${dockerhubRegistry}:${tag}", "--no-cache --build-arg VERSION=${buildVersion} --build-arg CACHE_DATE=$date .")
          
          // Github
          def githubImage = docker.build( "${githubRegistry}:${tag}", "--no-cache --build-arg VERSION=${buildVersion} --build-arg CACHE_DATE=$date .")
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
