pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build
    image: python:3.11-slim
    command:
    - cat
    tty: true
"""
        }
    }
    environment {
        GIT_CREDENTIAL = credentials('git-cred-token')
        DOCKER_TOKEN = credentials('docker_password')
        DOCKER_USERNAME = credentials('docker_username')
    }
    stages {
        stage('Checkout repository') {
            steps {
                script{
                    withCredentials([usernamePassword(credentialsId: 'git-cred-token', usernameVariable: 'git_username', passwordVariable: 'git_token')]) {
                        sh '''
                            git config --global user.name "testingGit"
                            git config --global user.email "testing@gmail.com"
                            git clone https://$git_username:$git_token@github.com/abiliokrismanuel/python-ci.git

                        '''
                    }
                }
            }
        }
        stage('Install dependencies (apk alpine)') {
            steps {
                sh  '''
                apt-get update
                apt-get install -y make gcc libffi-dev python3-dev
                
                '''
            }
        }
        stage('Install pip dependencies') {
            steps {
                sh 'make install'
            }
        }
        stage('Run tests') {
            steps {
                sh '''
                . venv/bin/activate
                pytest
                '''
            }
        }
        stage('Login to Docker Hub') {
            steps {
                sh '''
                echo "${DOCKER_TOKEN}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                '''
            }
        }
        stage('Set up Docker Buildx') {
            steps {
                sh '''
                docker buildx create --use
                '''
            }
        }
        stage('Build Docker image') {
            steps {
                sh '''
                docker buildx build -f .Dockerfile -t ${DOCKER_USERNAME}/python-ci:v2.0.0 . --push
                '''
            }
        }
    }
}
