pipeline {
    
   agent any

   parameters {
     string defaultValue: 'main', description: 'Branch name used to download the code from', name: 'BRANCH_NAME'
     choice choices: ['DEV', 'SIT', 'UAT'], name: 'Environment'
   } 
   
  options {
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')  
    timestamps()
    disableConcurrentBuilds()
    parallelsAlwaysFailFast()
  }


    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'actor', value: '$.repository.owner.name'],
                [key: 'branch', value: '$.ref']
            ],
            token: 'sampleapp',
            printContributedVariables: true,
            printPostContent: false,
            silentResponse: false,
            regexpFilterText: '$branch',
            regexpFilterExpression: 'refs/heads/' + BRANCH_NAME

        )
    }
	
  environment {
    SONAR_SCANNER = tool 'sonarqube-scanner'
  }

  stages {
    stage('code checkout') {
      steps {
        git branch: '$BRANCH_NAME', credentialsId: 'github-credentials', url: 'https://github.com/gkdevops/sample-nodejs.git'
      }
    }
    stage('npm dependencies') {
      steps {
        sh "npm install"
      }
    }
    stage('sonarqube scan') {
      steps {
        withSonarQubeEnv(installationName: 'sonarqube') {
	      sh "$SONAR_SCANNER/bin/sonar-scanner -Dproject.properties=sonar-project.properties"
	    }
      }
    }
    stage('docker image build & upload') {
      steps {
        sh '''
          docker image build -t chgoutam/mynodejs:$BUILD_ID.0.0 .
          docker image push chgoutam/mynodejs:$BUILD_ID.0.0
        '''
      }
    }
  } 
}
