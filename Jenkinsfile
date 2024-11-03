pipeline {
    agent {
        label "${env.pipehost}"
    }
    stages {
        stage ('Clone') {
            steps {
                sh "bash ./scripts/clone.sh"
            }
        }
        stage ('Build') {
            steps {
                sh "bash ./scripts/build.sh"
            }
        }
        stage ('Push') {
            steps {
                sh "bash ./scripts/push.sh"
            }
        }
        stage ('Pull') {
            steps {
                sh "bash ./scripts/pull.sh"
            }
        }
        stage ('Deploy') {
            steps {
                sh "bash ./scripts/deploy.sh"
            }
        }
    }
}