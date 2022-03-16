pipeline {
	
    agent any	
    
    parameters {
        choice choices: ['DEV', 'SIT', 'UAT', 'PROD'], description: '', name: 'ENVIRONMENT'
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
    
    stages {   
        
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
	  trivy --timeout 10m --exit-code 0  --severity "MEDIUM,HIGH,CRITICAL" mynodejs:${tag}${BUILD_ID}
	  #trivy --timeout 10m mynodejs:${tag}${BUILD_ID}
        '''
      }
    }
  }
}
