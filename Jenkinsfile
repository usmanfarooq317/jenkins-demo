pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'usmanfarooq317'
        IMAGE_NAME = 'jenkins-demo-app'
        IMAGE_TAG = 'latest'
        EC2_KEY = credentials('ec2-ssh-key')  // Upload PEM file in Jenkins as secret file
        EC2_USER = 'ubuntu'
        EC2_HOST = '54.89.241.89'
        SSH_KEY_PATH = '/tmp/clboth.pem'
    }

    stages {
        stage('Clone Repository') {
            steps {
                sh '''
                echo "Cloning repository..."
                rm -rf jenkins-demo || true
                git clone https://github.com/usmanfarooq317/jenkins-demo.git
                cd jenkins-demo
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                cd jenkins-demo
                docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Login & Push to Docker Hub') {
            steps {
                sh '''
                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_USERNAME --password-stdin
                docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                echo "Saving SSH key..."
                echo "$EC2_KEY" > $SSH_KEY_PATH
                chmod 600 $SSH_KEY_PATH

                echo "Deploying on EC2..."

                ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH $EC2_USER@$EC2_HOST << 'EOF'
                echo "Logging into EC2 instance..."
                
                # Stop old container if running
                docker rm -f jenkins-demo-container || true

                # Pull latest image from Docker Hub
                docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG

                # Run new container on port 6500
                docker run -d --name jenkins-demo-container -p 6500:6500 $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                EOF
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Code Pushed → Docker Built → Pushed → EC2 Deployed Successfully!'
        }
        failure {
            echo '❌ Failed. Check logs.'
        }
    }
}
