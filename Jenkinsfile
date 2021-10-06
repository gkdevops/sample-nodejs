pipeline {
    
  agent {
      label 'worker-01'
  }
    
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
        stage('deploy to development'){
            when {
                branch 'develop'
            }
            steps {
                echo "This code block only runs if the branch is develop"
            }
        }
        stage('deploy to production'){
            when {
                branch 'main'
            }
            steps {
                echo "This code block only runs if the branch is main branch"
            }
        }
  }
}
