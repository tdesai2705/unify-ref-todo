pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        BACKEND_IMAGE = 'tejasdesai27/todo-backend'
        FRONTEND_IMAGE = 'tejasdesai27/todo-frontend'
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
                sh 'git submodule update --init --recursive'
            }
        }
        
        stage('Build & Push Backend') {
            steps {
                dir('backend') {
                    echo "Building backend..."
                    sh """
                        docker build --platform linux/amd64 \
                            -t ${BACKEND_IMAGE}:${GIT_COMMIT_SHORT} \
                            -t ${BACKEND_IMAGE}:latest .
                        docker push ${BACKEND_IMAGE}:${GIT_COMMIT_SHORT}
                        docker push ${BACKEND_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Build & Push Frontend') {
            steps {
                dir('frontend') {
                    echo "Building frontend..."
                    sh """
                        docker build --platform linux/amd64 \
                            -t ${FRONTEND_IMAGE}:${GIT_COMMIT_SHORT} \
                            -t ${FRONTEND_IMAGE}:latest .
                        docker push ${FRONTEND_IMAGE}:${GIT_COMMIT_SHORT}
                        docker push ${FRONTEND_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Deploy to Dev') {
            steps {
                echo "Auto-deploying to Dev..."
                sh """
                    kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${GIT_COMMIT_SHORT} -n dev-todo-app
                    kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${GIT_COMMIT_SHORT} -n dev-todo-app
                """
            }
        }
        
        stage('Deploy to QA') {
            when { branch 'main' }
            steps {
                input message: 'Deploy to QA?', ok: 'Deploy'
                sh """
                    kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${GIT_COMMIT_SHORT} -n qa-todo-app
                    kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${GIT_COMMIT_SHORT} -n qa-todo-app
                """
            }
        }
        
        stage('Deploy to Prod') {
            when { branch 'main' }
            steps {
                input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
                sh """
                    kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${GIT_COMMIT_SHORT} -n prod-todo-app
                    kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${GIT_COMMIT_SHORT} -n prod-todo-app
                """
            }
        }
    }
    
    post {
        success {
            echo "✅ Deployed\!"
            echo "Dev: http://todo-app.34.75.0.106.nip.io"
        }
    }
}
