pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/usmanfarooq317/jenkins-demo.git'
            }
        }

        stage('Run Python Script') {
            steps {
                sh '''
                python3 app.py
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Python script executed successfully!'
        }
        failure {
            echo '❌ Something went wrong. Check logs.'
        }
    }
}
