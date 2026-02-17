node {
  
  stage('Clone') {
      dir('.') {
          git branch: 'main', credentialsId: 'github_com', url: 'git@github.com:Joel5040/Jenkins-CI-CD--Pipeline.git'
      }    
  }       

  stage('Deploy') {
     withCredentials([usernamePassword(
        credentialsId: 'Freestyle-Pass', 
        passwordVariable: 'MVN_PASSWORD', 
        usernameVariable: 'MVN_USERNAME')]) {

        sh """
          echo "Username: ${MVN_USERNAME}"
          echo "Password length: \${#MVN_PASSWORD}"
          mvn clean deploy -X \
              -s settings.xml \
              -Drepo.id=github \
              -Drepo.login=${MVN_USERNAME} \
              -Drepo.pwd=${MVN_PASSWORD} \
              -Drevision=1.${BUILD_NUMBER}
        """
     }
  }  

  stage('Docker Build') {
    sh """
      docker build -t joel5040/jenkins-ci-cd-app:1.${BUILD_NUMBER} .
      docker tag joel5040/jenkins-ci-cd-app:1.${BUILD_NUMBER} joel5040/jenkins-ci-cd-app:latest
    """
  }

  stage('Docker Push') {
    withCredentials([usernamePassword(
        credentialsId: 'docker-hub', 
        passwordVariable: 'DOCKER_PASSWORD', 
        usernameVariable: 'DOCKER_USERNAME')]) {

        sh """
          echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin
          docker push joel5040/jenkins-ci-cd-app:1.${BUILD_NUMBER}
          docker push joel5040/jenkins-ci-cd-app:latest
          docker logout
        """
    }
  }

  stage('Post') {
    jacoco()
    junit 'target/surefire-reports/*.xml'
    def pmd = scanForIssues tool: [$class: 'Pmd'], pattern: 'target/pmd.xml'
    publishIssues issues: [pmd]
  }
  
}