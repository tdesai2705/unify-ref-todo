#!/bin/bash
# Deploy Todo-App to Anudeep's GKE Cluster
# Run this after getting GKE access

set -e

echo "🚀 Deploying Todo-App to GKE (unifyintegration cluster)"
echo "=================================================="

# Create namespaces
echo ""
echo "📦 Creating namespaces..."
kubectl create namespace dev-todo-app --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace qa-todo-app --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod-todo-app --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespaces created"

# Deploy to Dev
echo ""
echo "🔧 Deploying to Dev environment..."
cd infrastructure

# PostgreSQL
echo "  - Deploying PostgreSQL..."
kubectl apply -f kubernetes/dev/postgres-statefulset.yaml
kubectl apply -f kubernetes/dev/postgres-service.yaml

echo "  - Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n dev-todo-app --timeout=180s || echo "Warning: PostgreSQL may not be ready yet"

# Backend
echo "  - Deploying Backend..."
kubectl apply -f kubernetes/dev/backend-deployment.yaml
kubectl apply -f kubernetes/dev/backend-service.yaml

# Frontend
echo "  - Deploying Frontend..."
kubectl apply -f kubernetes/dev/frontend-deployment.yaml
kubectl apply -f kubernetes/dev/frontend-service.yaml

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment/backend -n dev-todo-app --timeout=180s || echo "Warning: Backend may not be ready yet"
kubectl wait --for=condition=available deployment/frontend -n dev-todo-app --timeout=180s || echo "Warning: Frontend may not be ready yet"

echo ""
echo "📊 Deployment Status:"
kubectl get pods -n dev-todo-app
kubectl get services -n dev-todo-app

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Initialize database:"
echo "   kubectl exec -it -n dev-todo-app deployment/backend -- flask db init"
echo "   kubectl exec -it -n dev-todo-app deployment/backend -- flask db migrate -m 'Initial schema'"
echo "   kubectl exec -it -n dev-todo-app deployment/backend -- flask db upgrade"
echo ""
echo "2. Test the application:"
echo "   kubectl port-forward -n dev-todo-app deployment/frontend 8080:5001"
echo "   Open: http://localhost:8080"
echo ""
echo "3. Check logs:"
echo "   kubectl logs -n dev-todo-app deployment/backend -f"
echo "   kubectl logs -n dev-todo-app deployment/frontend -f"
