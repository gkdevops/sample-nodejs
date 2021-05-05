pipeline {
    
    agent any
    
    parameters {
        string defaultValue: 'main', description: 'This parameter will expect the branch name to be provided', name: 'BRANCH_NAME', trim: false
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
        stage ('Code Checkout'){
            steps {
                echo "This is stage 1"
                git branch: '$BRANCH_NAME', url: 'https://github.com/gkdevops/sample-nodejs.git'
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
        
        stage ('Build & Push Image'){
            steps {
                sh '''
                image_tag=`git rev-parse --short HEAD`
                docker image build -t 131733961504.dkr.ecr.us-east-1.amazonaws.com/sample-app:$image_tag .
                docker push 131733961504.dkr.ecr.us-east-1.amazonaws.com/sample-app:$image_tag
                '''
            }
        }
    }
}
