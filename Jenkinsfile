pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'usmanfarooq317'
        IMAGE_NAME = 'jenkins-demo-app'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/usmanfarooq317/jenkins-demo.git'
            }
        }

        stage('Run Python App') {
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

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                    echo "Building Docker image..."
                    docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo "Logging in to Docker Hub..."
                    echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh '''
                    echo "Pushing Docker Image to Docker Hub..."
                    docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Run Container (Optional)') {
            steps {
                script {
                    sh '''
                    echo "Running Docker container on port 6500..."
                    docker rm -f jenkins-demo-container || true
                    docker run -d --name jenkins-demo-container -p 6500:6500 $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
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
            echo '✅ Build, Test & Docker Push Successful!'
        }
        failure {
            echo '❌ Something went wrong. Check logs.'
        }
    }
}
