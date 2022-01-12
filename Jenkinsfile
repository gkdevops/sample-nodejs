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
          sudo docker image build -t mycounterapp:${tag}${BUILD_ID} .
          sudo docker image tag mycounterapp:${tag}${BUILD_ID} chgoutam/mycounterapp:${tag}${BUILD_ID}
          sudo docker image push chgoutam/mycounterapp:${tag}${BUILD_ID}
        '''
      }
    }

    stage ('Docker Image Scan'){
      steps {
        sh '''
	  tag=`git log --format="%H" -n 1 | cut -c 1-7`
	  #trivy --timeout 10m --exit-code 1  --severity "MEDIUM,HIGH,CRITICAL" mycounterapp:${tag}${BUILD_ID}
	  trivy --timeout 10m --severity "MEDIUM,HIGH,CRITICAL" mycounterapp:${tag}${BUILD_ID}
        '''
      }
    }
        stage('deploy to develop environment'){
            when {
                branch 'develop'
            }
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                      input message: 'Approve Deployment?', ok: 'Yes'    
                    }
                }
            }
        }
        
        stage('deploy to production environment'){
            when {
                branch 'main'
            }
            steps {
                withCredentials([file(credentialsId: 'kubernetes-dev-cluster', variable: 'kubeconfig')]) {
                    sh '''
                    tag=`git log --format="%H" -n 1 | cut -c 1-7`
                    helm upgrade --install --set image.tag=${tag}${BUILD_ID} --kubeconfig=${kubeconfig} counter-app ./helmchart
                    '''
                }
            }
        }
        stage('Kubernetes Health Check'){
            when {
                branch 'main'
            }
            steps {
                withCredentials([file(credentialsId: 'kubernetes-dev-cluster', variable: 'kubeconfig')]) {
                    sh '''
		    kubectl wait --for=condition=ready pod -l app=sampleapp --timeout=30s --kubeconfig=${kubeconfig}
                    '''
                }
            }
	        post {
		  success {
                    echo 'This logic will get exeucted when the above stage is successful'
                  }
		  failure {
                    	echo 'This logic will get exeucted when the above stage is failed'
                  }
	       }
      }
  }
}
