pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Pull code from GitHub
                git branch: 'main', url: 'https://github.com/usmanfarooq317/jenkins-demo.git'
            }
        }

        stage('Setup Python') {
            steps {
                // Setup virtual environment and install dependencies
                sh '''
                python3 -m venv venv
                source venv/bin/activate
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Python Script') {
            steps {
                // Run the Python script
                sh '''
                source venv/bin/activate
                python3 app.py
                '''
            }
        }
    }

    post {
        success {
            echo 'Build and Python script executed successfully!'
        }
        failure {
            echo 'Something went wrong. Check the build logs.'
        }
    }
}
