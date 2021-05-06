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
        
        stage ('Regression Testing'){
            when { 
                branch 'master'
            }
            steps {
                echo "This is a testing stage"
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
        
        stage ('Deploy to Kubernetes'){
            steps {
                withCredentials([string(credentialsId: 'kubeconfig-dev', variable: 'kubeconfig-develop')]) {
                    sh '''
                    image_tag=`git rev-parse --short HEAD`
                    helm upgrade example ./helmchart --set image.tag=$image_tag --kubeconfig=${kubeconfig-develop}
                    '''
                }
            }
        }    
    }
}
