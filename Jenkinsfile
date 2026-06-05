pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-agents
  containers:
  - name: kubectl
    image: alpine/k8s:1.28.3
    command:
    - sleep
    args:
    - 99d
"""
        }
    }

    environment {
        BACKEND_IMAGE = 'tejasdesai27/todo-backend'
        FRONTEND_IMAGE = 'tejasdesai27/todo-frontend'
    }

    stages {
        stage('Deploy to Dev') {
            steps {
                container('kubectl') {
                    echo "Auto-deploying to Dev..."
                    sh """
                        kubectl set image deployment/backend backend=${BACKEND_IMAGE}:latest -n dev-todo-app
                        kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:latest -n dev-todo-app
                        kubectl rollout status deployment/backend -n dev-todo-app
                        kubectl rollout status deployment/frontend -n dev-todo-app
                    """
                }
            }
        }

        stage('Deploy to QA') {
            when { branch 'main' }
            steps {
                input message: 'Deploy to QA?', ok: 'Deploy'
                container('kubectl') {
                    sh """
                        kubectl set image deployment/backend backend=${BACKEND_IMAGE}:latest -n qa-todo-app
                        kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:latest -n qa-todo-app
                        kubectl rollout status deployment/backend -n qa-todo-app
                        kubectl rollout status deployment/frontend -n qa-todo-app
                    """
                }
            }
        }

        stage('Deploy to Prod') {
            when { branch 'main' }
            steps {
                input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
                container('kubectl') {
                    sh """
                        kubectl set image deployment/backend backend=${BACKEND_IMAGE}:latest -n prod-todo-app
                        kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:latest -n prod-todo-app
                        kubectl rollout status deployment/backend -n prod-todo-app
                        kubectl rollout status deployment/frontend -n prod-todo-app
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployed!"
            echo "Dev: http://todo-app.34.75.0.106.nip.io"
            echo "QA: http://todo-app-qa.34.75.0.106.nip.io"
            echo "Prod: http://todo-app-prod.34.75.0.106.nip.io"
        }
    }
}
