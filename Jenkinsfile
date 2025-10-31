pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/usmanfarooq317/jenkins-demo.git'
            }
        }

        stage('Setup Python') {
            steps {
                // Use bash to run commands
                sh '''#!/bin/bash
                python3 -m venv venv
                source venv/bin/activate
                pip install -r requirements.txt || echo "No requirements.txt found"
                '''
            }
        }

        stage('Run Python Script') {
            steps {
                sh '''#!/bin/bash
                source venv/bin/activate
                python3 app.py
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build and Python script executed successfully!'
        }
        failure {
            echo '❌ Something went wrong. Check the build logs.'
        }
    }
}
