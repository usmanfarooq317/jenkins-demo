# jenkins-demo

A minimal demo repository that shows a simple Python app, a test, a Dockerfile, and a Jenkins pipeline (Jenkinsfile) that builds a Docker image, pushes it to Docker Hub, and deploys it to an EC2 instance.

This project is intended as a learning/example repository to demonstrate:
- running a simple Python script
- a basic test file
- building and running a Docker image
- a Jenkins pipeline with build  push  deploy stages

---

## Repository structure

- `app.py`  simple Python script (prints messages).
- `test_app.py`  basic unit test for the example message.
- `Dockerfile`  builds a small image from `python:3.10-slim` and runs `app.py`.
- `Jenkinsfile`  pipeline that builds the Docker image, logs into Docker Hub, pushes the image, and uses SSH to deploy the image on an EC2 host.
- `README.md`  (this file)

---

## Requirements

Locally:
- git
- Docker (to build and run the image)
- Python 3.8+ (to run the script and tests)
- pytest (optional for running tests)

For Jenkins pipeline:
- Jenkins with Docker installed on the Jenkins agent (so `docker` commands run)
- Credentials set in Jenkins:
  - `dockerhub-credentials` (username/password credential for Docker Hub)
  - `ec2-ssh-key` (SSH private key credential to access your EC2 instance)
- An EC2 host accessible via SSH and with Docker installed
- Security Group for EC2 must allow SSH (port 22) and application port (6500) if needed

---

## Quick start  local

1. Clone the repository:
   ```
   git clone https://github.com/usmanfarooq317/jenkins-demo.git
   cd jenkins-demo
   ```

2. Run the Python app directly:
   ```
   python3 app.py
   ```
   Expected output:
   ```
   Hello from Jenkins Python build!
   Hello World!
   ```

   Note: `app.py` is a simple script that prints and exits. The Docker container built from this will also exit immediately after the script finishes. See "Keep container running" below if you want a long-running service.

3. Run the test
   - With pytest:
     ```
     pytest -q
     ```
   - Or execute the test file directly:
     ```
     python3 test_app.py
     ```
     Expected output:
     ```
     ✅ Test passed successfully!
     ```

---

## Docker

The repository includes a `Dockerfile` which:

- uses `python:3.10-slim`
- copies the repository into `/app`
- attempts to `pip install -r requirements.txt` (the command is `|| true` so build won't fail if `requirements.txt` is absent)
- exposes port `6500`
- runs `python3 app.py`

Build image locally:
```
docker build -t usmanfarooq317/jenkins-demo-app:latest .
```

Run container locally:
```
docker run --rm --name jenkins-demo -p 6500:6500 usmanfarooq317/jenkins-demo-app:latest
```
Because `app.py` prints messages and exits, the container will stop immediately. If you need a persistent service you must change `app.py` to run a web server (Flask/uvicorn/gunicorn) or wrap it with a sleep/loop for demo purposes.

Example (quick hack to keep the container alive; NOT for production):
- Replace `app.py` with:
  ```python
  from time import sleep
  print("Hello from Jenkins Python build!")
  print("Hello World!")
  while True:
      sleep(60)
  ```
- Then rebuild the Docker image.

---

## Push to Docker Hub (manual)

1. Login:
   ```
   docker login
   ```
   or
   ```
   docker login -u <username> -p <password>
   ```

2. Tag & push:
   ```
   docker tag usmanfarooq317/jenkins-demo-app:latest <your-dockerhub-username>/jenkins-demo-app:latest
   docker push <your-dockerhub-username>/jenkins-demo-app:latest
   ```

Note: The Jenkins pipeline uses the image name `usmanfarooq317/jenkins-demo-app:latest` as set in the `Jenkinsfile`. Make sure that the Docker Hub repository exists (or is auto-created if your Docker Hub account allows it).

---

## Jenkins pipeline (Jenkinsfile)  explanation

The pipeline in `Jenkinsfile` consists of these stages:

1. Clone Repository
   - Clones `https://github.com/usmanfarooq317/jenkins-demo.git` branch `main`.

2. Build Docker Image
   - Runs: `docker build -t $DOCKER_IMAGE .`
   - `DOCKER_IMAGE` is defined in pipeline environment as `usmanfarooq317/jenkins-demo-app:latest`.

3. Login & Push to Docker Hub
   - Uses Jenkins credentials `dockerhub-credentials` (username/password).
   - Runs:
     ```
     echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
     docker push $DOCKER_IMAGE
     ```

4. Deploy to EC2
   - Uses Jenkins credential `ec2-ssh-key` (SSH private key).
   - SSH to `$EC2_USER@$EC2_HOST`, then:
     - `docker pull $DOCKER_IMAGE`
     - Stop & remove old container (`jenkins-demo-container`)
     - Run new container:
       ```
       docker run -d --name jenkins-demo-container -p 6500:6500 $DOCKER_IMAGE
       ```
   - Note: The pipeline uses `EC2_USER = 'ubuntu'` and `EC2_HOST = '54.89.241.89'` in the Jenkinsfile  change `EC2_HOST` to your instance's IP or set this as a Jenkins environment variable.

Post actions:
- Success and failure messages printed in Jenkins.

---

## Setting up Jenkins credentials

1. Docker Hub credentials:
   - Jenkins > Credentials > (global) > Add Credentials
   - Kind: Username with password
   - ID: `dockerhub-credentials`
   - Username: your Docker Hub username
   - Password: your Docker Hub password or token

2. EC2 SSH key:
   - Kind: SSH Username with private key (or Secret file/SSH key depending on your Jenkins)
   - ID: `ec2-ssh-key`
   - You may also use "Secret text" containing PEM and reference it accordingly; the provided Jenkinsfile expects the credential to be available to `ssh -i $EC2_KEY` (adjust how Jenkins injects the key if needed).

3. Configure `EC2_HOST` in the Jenkinsfile or set a pipeline-level environment variable (or use Jenkins parameters) and make sure the IP matches your target EC2 instance.

---

## EC2 host preparation

On the EC2 instance (`EC2_USER`@`EC2_HOST`):
- Docker must be installed and configured to run without sudo (or adjust commands to use `sudo`).
- The security group must allow:
  - SSH (port 22) from Jenkins server
  - Application port 6500 (if you want to access the demo externally)
- Verify you can SSH from your Jenkins instance to the EC2 host using the private key configured in Jenkins.

---

## Common issues & troubleshooting

- Container exits immediately:
  - `app.py` currently prints messages and exits. Either convert the app into a server (Flask/FastAPI) or add a loop/sleep to keep it running.
- Docker not found on Jenkins agent:
  - Ensure Docker CLI is installed and the Jenkins user can run docker. Use `docker` or configure Jenkins to run pipeline on a node with Docker.
- Permission/SSH failures:
  - Ensure `ec2-ssh-key` is the correct private key and has proper permissions, and the public key exists in `~/.ssh/authorized_keys` on EC2.
- Docker Hub push fails:
  - Ensure credentials are correct and the target repository/tag is allowed. Consider using a Docker Hub access token.

---

## How to modify this repository to run a real web app

1. Add a `requirements.txt`:
   ```
   flask
   gunicorn
   ```
2. Replace `app.py` with a simple Flask app:
   ```python
   from flask import Flask
   app = Flask(__name__)

   @app.route('/')
   def home():
       return "Hello from Jenkins Python build!"

   if __name__ == "__main__":
       app.run(host="0.0.0.0", port=6500)
   ```
3. Update the `Dockerfile` to use Gunicorn for production:
   ```
   FROM python:3.10-slim
   WORKDIR /app
   COPY . .
   RUN pip install -r requirements.txt
   EXPOSE 6500
   CMD ["gunicorn", "-b", "0.0.0.0:6500", "app:app"]
   ```
4. Rebuild and push image or run locally.

---

## Notes & recommendations

- The example is intentionally minimal. For production use:
  - Use a proper CI/CD process with image tags (not always `latest`).
  - Use health checks, logging, monitoring, and process managers.
  - Secure SSH and credentials; prefer immutable infrastructure or container orchestration (ECS, Kubernetes).
  - Add unit tests and linting to the pipeline.

---

If you'd like, I can:
- Open a PR that replaces the minimal `app.py` with a persistent Flask app and update the Dockerfile and tests.
- Or commit this README.md into the repository for you (I will need repository push permission / to run the commit if you want me to proceed).
