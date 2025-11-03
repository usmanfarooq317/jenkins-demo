pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        EC2_KEY = credentials('ec2-ssh-key') // Jenkins → Credentials → SSH Key
        DOCKER_IMAGE = 'usmanfarooq317/jenkins-demo-app:latest'
        EC2_USER = 'ubuntu'    // Change if your EC2 AMI has a different username
        EC2_HOST = '54.89.241.89'  // <- Replace this
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git url: 'https://github.com/usmanfarooq317/jenkins-demo.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Login & Push to Docker Hub') {
            steps {
                echo 'Logging in to Docker Hub...'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $DOCKER_IMAGE'
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying on EC2...'
                sh """
                ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST '
                    echo "Pulling latest Docker image..."
                    docker pull $DOCKER_IMAGE || true

                    echo "Stopping old container..."
                    docker stop jenkins-demo-container || true
                    docker rm jenkins-demo-container || true

                    echo "Running new container on port 6500..."
                    docker run -d --name jenkins-demo-container -p 6500:6500 $DOCKER_IMAGE
                '
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed! Check the error logs."
        }
    }
}
