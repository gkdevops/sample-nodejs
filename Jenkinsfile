pipeline {
	
    agent any	
    
    parameters {
        choice choices: ['DEV', 'SIT', 'UAT', 'PROD'], description: '', name: 'ENVIRONMENT'
        string defaultValue: 'main', description: 'Branch name used to download the code from', name: 'BRANCH_NAME'
    }
    
    stages {   
        
        stage('code checkout') {
            steps {
                git branch: '$BRANCH_NAME', credentialsId: 'github-credentials', url: 'https://github.com/gkdevops/sample-nodejs.git'
            }
        }

        stage('Initialize Build'){
            steps {
                echo "Starting the Build"
            }
        }
        
        stage('Parallel Stages'){
            parallel {
                stage('Node Dependecy'){
                    steps {
                        sh "npm install"
                    }
                }
                stage('SonarQube'){
                    environment {
                        SONAR_SCANNER = tool 'sonarqube-scanner'
                    }
                    steps {
                        withSonarQubeEnv (installationName: 'sonarqube-server') {
                            sh "$SONAR_SCANNER/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
                        }
                    }
                }
            }
        }
        
    stage ('Docker build and Push'){
      steps {
        sh '''
          tag=`git log --format="%H" -n 1 | cut -c 1-7`
          sudo docker image build -t mynodejs:${tag}${BUILD_ID} .
          sudo docker image tag mynodejs:${tag}${BUILD_ID} chgoutam/mynodejs:${tag}${BUILD_ID}
          sudo docker image push chgoutam/mynodejs:${tag}${BUILD_ID}
        '''
      }
    }

    stage ('Docker Image Scan'){
      steps {
        sh '''
	  tag=`git log --format="%H" -n 1 | cut -c 1-7`
	  #trivy --timeout 10m --exit-code 1  --severity "MEDIUM,HIGH,CRITICAL" mynodejs:${tag}${BUILD_ID}
	  trivy --timeout 10m --severity "MEDIUM,HIGH,CRITICAL" mynodejs:${tag}${BUILD_ID}
        '''
      }
    }
    stage('Aproval for main branch'){
    	when {
            branch 'main'
        }
        steps {
            script {
                timeout(time: 10, unit: 'HOURS') {
                    input message: 'Approve Deployment?', ok: 'Yes' 
                 }
             }
         }
      }
  }
}
