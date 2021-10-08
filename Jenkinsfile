//////// Variables /////////
def image_name = "ghcr.io/iceoid/minecraft-bedrock-docker"
def tag = "latest"
pipeline 
{
  
  agent any
  
  stages
  {
    stage("Build")
    {
      steps
      {
        echo "Build Stage."
        echo "building: ${image_name}:${tag}"
        sh 'docker build . -t ${image_name}:${tag}'
      }
    }
    stage("Deploy")
    {
      steps
      {
        echo "Deploy Stage."
        //TODO: Push to ghcr.io and dockerhub
        withCredentials([string(credentialsId: 'GHCR_TOKEN_JENKINS', variable: 'GHCR_TOKEN_JENKINS')])
        {
          sh 'docker login ghcr.io -u iceoid -p ${GHCR_TOKEN_JENKINS}'
          sh 'docker push ${image_name}:${tag}'
        }
         
      }
    }
  }

}
