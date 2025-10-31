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
                echo "Running main Python app..."
                python3 app.py > output.log
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                echo "Running tests..."
                python3 test_app.py >> output.log
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'output.log', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ Build, test, and artifact archive successful!'
        }
        failure {
            echo '❌ Build or test failed. Check logs.'
        }
    }
}
