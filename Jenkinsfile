pipeline {
    
    agent any
    
    parameters {
        string defaultValue: 'main', description: 'This parameter will expect the branch name to be provided', name: 'BRANCH_NAME', trim: false
        choice choices: ['DEV', 'SIT', 'UAT', 'PROD'], description: '', name: 'ENVIRONMENT'
    }
    
    stages {
        stage ('Code Checkout'){
            steps {
                echo "This is stage 1"
                git branch: '$BRANCH_NAME', url: 'https://github.com/gkdevops/sample-nodejs.git'
            }
        }
        
        stage('Stage 2'){
            steps {
                echo "This is stage 2"
                echo "The value of the environment is $ENVIRONMENT"
            }
        }
    }
}
