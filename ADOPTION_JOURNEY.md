# CloudBees Unify Adoption Journey
## 2-Tier To-Do Application - Complete Implementation Guide

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Week 1: Setup & Initial Deployment](#week-1-setup--initial-deployment)
4. [Week 2: Smart Tests & Feature Management](#week-2-smart-tests--feature-management)
5. [Week 3: Release Orchestration](#week-3-release-orchestration)
6. [Week 4: Security & DORA Metrics](#week-4-security--dora-metrics)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This adoption journey guides you through implementing a complete CloudBees Unify reference architecture using a 2-tier to-do application. By the end, you'll have hands-on experience with all major Unify features.

**What You'll Learn:**
- CI/CD workflows and automation
- Smart Tests (AI-powered test subsetting)
- Security scanning (SAST, SCA, Secrets)
- Feature Management (Cask)
- Release Orchestration
- DORA metrics tracking
- Multi-environment deployment
- Evidence collection

**Time Commitment:** 4 weeks (5-10 hours per week)

---

## Prerequisites

### Required Accounts
- [ ] GitHub account
- [ ] Docker Hub account
- [ ] CloudBees Unify account
- [ ] Kubernetes cluster access (GKE, EKS, or local)

### Required Tools
- [ ] `git` (2.30+)
- [ ] `docker` (20.10+)
- [ ] `kubectl` (1.25+)
- [ ] `python` (3.11+)
- [ ] Code editor (VS Code recommended)

### Knowledge Requirements
- Basic Python/Flask understanding
- Basic Docker knowledge
- Basic Kubernetes concepts
- Git fundamentals

---

## Week 1: Setup & Initial Deployment

### **Day 1: Environment Setup**

#### Step 1.1: Clone the Repository
```bash
# Clone with all submodules
git clone --recursive https://github.com/tdesai2705/unify-ref-todo.git
cd unify-ref-todo

# If already cloned, initialize submodules
git submodule update --init --recursive
```

**✅ Checkpoint:** You should see 7 subdirectories (backend, frontend, database, etc.)

#### Step 1.2: Verify Local Environment
```bash
# Check Python
python --version  # Should be 3.11+

# Check Docker
docker --version
docker ps  # Verify Docker is running

# Check kubectl
kubectl version --client
```

**✅ Checkpoint:** All commands should succeed

---

### **Day 2: Local Development Setup**

#### Step 2.1: Start Local Database
```bash
cd database
docker-compose up -d

# Verify PostgreSQL is running
docker ps | grep postgres
```

**✅ Checkpoint:** PostgreSQL container should be running on port 5432

#### Step 2.2: Run Backend Locally
```bash
cd ../backend

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DATABASE_URL="postgresql://todouser:todopass@localhost:5432/todos"
export SECRET_KEY="dev-secret-key"

# Run migrations (if using Flask-Migrate)
flask db upgrade

# Start backend
python run.py
```

**✅ Checkpoint:** Backend should be running on http://localhost:5000
Test: `curl http://localhost:5000/health`

#### Step 2.3: Run Frontend Locally
```bash
cd ../frontend

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export BACKEND_API_URL="http://localhost:5000/api"
export SECRET_KEY="dev-secret-key"

# Start frontend
python run.py
```

**✅ Checkpoint:** Frontend should be running on http://localhost:5001
Test: Open browser to http://localhost:5001

---

### **Day 3: CloudBees Unify Setup**

#### Step 3.1: Create CloudBees Unify Organization
1. Log in to CloudBees Unify (https://app.cloudbees.io)
2. Click "Create Organization"
3. Name: `your-name-unify-reference`
4. Save organization ID for later

**✅ Checkpoint:** Organization created successfully

#### Step 3.2: Create Backend Component
1. Go to your organization
2. Click "Add Component"
3. Fill in details:
   - **Name**: `todo-backend`
   - **Repository**: `github.com/tdesai2705/unify-ref-todo-backend`
   - **Branch**: `main`
   - **Workflow path**: `.cloudbees/workflows/backend-build.yaml`
4. Click "Create"

**✅ Checkpoint:** Backend component appears in component list

#### Step 3.3: Create Frontend Component
1. Click "Add Component"
2. Fill in details:
   - **Name**: `todo-frontend`
   - **Repository**: `github.com/tdesai2705/unify-ref-todo-frontend`
   - **Branch**: `main`
   - **Workflow path**: `.cloudbees/workflows/frontend-build.yaml`
3. Click "Create"

**✅ Checkpoint:** Frontend component appears in component list

#### Step 3.4: Configure Secrets
1. Go to Organization Settings → Secrets
2. Add the following secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub token
   - `KUBECONFIG`: Your Kubernetes config (base64 encoded)

**✅ Checkpoint:** All secrets configured

---

### **Day 4: First Build**

#### Step 4.1: Trigger Backend Build
1. Go to `todo-backend` component
2. Click "Workflows" tab
3. Click "Run Workflow" on `backend-build.yaml`
4. Select branch: `main`
5. Click "Run"

**⏰ Expected Duration:** 5-8 minutes

**✅ Checkpoint:** Build succeeds with green checkmark

#### Step 4.2: Verify Build Artifacts
1. Check workflow logs
2. Verify steps completed:
   - ✅ Unit tests passed
   - ✅ Security scan completed
   - ✅ Docker image pushed
3. Check Docker Hub for image: `tejasdesai27/todo-backend:latest`

**✅ Checkpoint:** Docker image visible in Docker Hub

#### Step 4.3: Trigger Frontend Build
1. Go to `todo-frontend` component
2. Click "Workflows" tab
3. Click "Run Workflow"
4. Select branch: `main`
5. Click "Run"

**⏰ Expected Duration:** 3-5 minutes

**✅ Checkpoint:** Build succeeds, Docker image pushed

---

### **Day 5: Deploy to Dev Environment**

#### Step 5.1: Prepare Kubernetes Cluster
```bash
cd infrastructure

# Verify kubectl access
kubectl cluster-info

# Review dev manifests
ls kubernetes/dev/
```

**✅ Checkpoint:** kubectl can connect to cluster

#### Step 5.2: Deploy Application
```bash
# Run deployment script
./deploy.sh dev

# Wait for deployment to complete
# This will:
# 1. Create namespace (dev-todo-app)
# 2. Deploy PostgreSQL StatefulSet
# 3. Deploy Backend Deployment
# 4. Deploy Frontend Deployment
# 5. Create Services and Ingress
```

**⏰ Expected Duration:** 5-10 minutes

**✅ Checkpoint:** All pods running
```bash
kubectl get pods -n dev-todo-app
# Should show:
# postgres-0                1/1     Running
# backend-xxxxxxxxx-xxxxx   1/1     Running
# backend-xxxxxxxxx-xxxxx   1/1     Running
# frontend-xxxxxxxxx-xxxxx  1/1     Running
# frontend-xxxxxxxxx-xxxxx  1/1     Running
```

#### Step 5.3: Verify Deployment
```bash
# Check services
kubectl get svc -n dev-todo-app

# Check ingress
kubectl get ingress -n dev-todo-app

# Test backend health
kubectl port-forward service/backend-service 5000:5000 -n dev-todo-app &
curl http://localhost:5000/health

# Test frontend
kubectl port-forward service/frontend-service 5001:5001 -n dev-todo-app &
curl http://localhost:5001/health
```

**✅ Checkpoint:** All services healthy

---

### **Week 1 Summary**

**What You Accomplished:**
- ✅ Set up local development environment
- ✅ Created CloudBees Unify organization
- ✅ Created backend and frontend components
- ✅ Ran first builds in Unify
- ✅ Deployed to Kubernetes (dev environment)

**Next Week:** Smart Tests integration and Feature Management

---

## Week 2: Smart Tests & Feature Management

### **Day 1: Enable Smart Tests Observation Mode**

#### Step 2.1: Update Backend Workflow
Copy the Smart Tests configuration to your backend repository:

```bash
cd backend
cp ../workflows/smart-tests-config.yaml .
git add smart-tests-config.yaml
git commit -m "Add Smart Tests configuration (observation mode)"
git push origin main
```

#### Step 2.2: Update Workflow to Use Smart Tests
The workflow in `.cloudbees/workflows/backend-build.yaml` already includes Smart Tests. Verify it's configured:

```yaml
smart-tests:
  steps:
    - name: Configure Smart Tests
      uses: cloudbees-io/smart-tests@v1
      with:
        mode: observation  # Change to observation for learning
        test-command: pytest tests/
        confidence: 0.9
```

**✅ Checkpoint:** Smart Tests in observation mode

#### Step 2.3: Make 5-10 Commits
Smart Tests needs to learn your codebase. Make small changes and commit:

```bash
# Example changes:
# Commit 1: Update a comment in app/models.py
# Commit 2: Add a docstring to a function
# Commit 3: Update a test case
# Commit 4: Refactor a route handler
# Commit 5: Update validation logic

# After each change:
git add .
git commit -m "Your change description"
git push origin main
```

**✅ Checkpoint:** 5-10 commits pushed, all builds passing

---

### **Day 2: Enable Smart Tests Subsetting**

#### Step 2.4: Switch to Subsetting Mode
After 5-10 commits in observation mode:

```bash
cd backend

# Edit smart-tests-config.yaml
# Change mode: observation → mode: subsetting

git add smart-tests-config.yaml
git commit -m "Enable Smart Tests subsetting mode"
git push origin main
```

#### Step 2.5: Verify Smart Tests Working
1. Make a small code change (e.g., update app/routes.py)
2. Commit and push
3. Watch the build in Unify
4. Check logs for "Smart Tests: Running X of Y tests"

**✅ Checkpoint:** Smart Tests is subsetting (running fewer tests)

**Expected Results:**
- Before: Runs all 39 tests (~8 minutes)
- After: Runs 15-20 relevant tests (~3-5 minutes)
- **50-60% time savings!**

---

### **Day 3: Set Up Feature Management (Cask)**

#### Step 2.6: Create Cask Account
1. Go to CloudBees Feature Management (Cask)
2. Sign up or log in
3. Create new project: "todo-app"
4. Copy API key

**✅ Checkpoint:** Cask account created, API key saved

#### Step 2.7: Configure Feature Flags in Unify
1. Add Cask secret to Unify:
   - Go to Organization Settings → Secrets
   - Add secret: `CASK_API_KEY` = your-api-key

2. Run Feature Management workflow:
   - Go to Workflows
   - Select "Feature Management Setup"
   - Click "Run Workflow"
   - Choose environment: `dev`
   - Click "Run"

**✅ Checkpoint:** Feature flags created in Cask

#### Step 2.8: Verify Feature Flags
1. Log in to Cask dashboard
2. Navigate to your project
3. You should see two flags:
   - `due-date-feature` (OFF by default)
   - `dark-mode` (OFF by default)

**✅ Checkpoint:** Flags visible in Cask UI

---

### **Day 4: Test Feature Flags**

#### Step 2.9: Toggle Due Date Feature
1. In Cask UI, toggle `due-date-feature` to ON
2. Save changes
3. Open frontend application: http://localhost:5001 (or your ingress URL)
4. Try to add a new todo
5. You should now see a "Due Date" field in the form

**✅ Checkpoint:** Due date field appears when flag is ON, hidden when OFF

#### Step 2.10: Toggle Dark Mode
1. In Cask UI, toggle `dark-mode` to ON
2. Save changes
3. Refresh the frontend
4. UI should switch to dark theme

**✅ Checkpoint:** Dark mode toggles without redeployment

---

### **Day 5: Integration Testing**

#### Step 2.11: Run Robot Framework Tests Locally
```bash
cd tests-integration

# Install dependencies
pip install -r requirements.txt

# Ensure backend is running (localhost:5000)
# Run tests
./run_tests.sh

# View results
open results/report.html
```

**✅ Checkpoint:** 14 tests pass

#### Step 2.12: Run Integration Tests in Unify
1. Go to Workflows in Unify
2. Trigger "Integration Tests" workflow
3. Watch as it:
   - Starts PostgreSQL container
   - Starts Backend container
   - Runs Robot Framework tests
   - Publishes results

**✅ Checkpoint:** Integration tests pass in Unify

---

### **Week 2 Summary**

**What You Accomplished:**
- ✅ Enabled Smart Tests (observation → subsetting)
- ✅ Achieved 50-60% CI/CD time savings
- ✅ Set up Feature Management (Cask)
- ✅ Created and tested feature flags
- ✅ Toggled features without redeployment
- ✅ Ran integration tests locally and in Unify

**Next Week:** Release Orchestration and Multi-Environment Deployment

---

## Week 3: Release Orchestration

### **Day 1: Set Up QA Environment**

#### Step 3.1: Deploy to QA
```bash
cd infrastructure

# Deploy QA environment
./deploy.sh qa

# Verify deployment
kubectl get all -n qa-todo-app
```

**✅ Checkpoint:** QA environment running

#### Step 3.2: Update Ingress for QA
Edit `kubernetes/qa/ingress.yaml` with your domain, then apply:
```bash
kubectl apply -f kubernetes/qa/ingress.yaml
```

**✅ Checkpoint:** QA accessible via ingress URL

---

### **Day 2: Configure Release Orchestration**

#### Step 3.3: Update Release Workflow
The release orchestration workflow is already in `workflows/.cloudbees/workflows/release-orchestration.yaml`. Review the flow:

```
Push to main
    ↓
Deploy Dev (auto)
    ↓
[QA Approval] ← You approve here
    ↓
Deploy QA
    ↓
Smoke Tests
    ↓
[Prod Approval] ← You approve here
    ↓
Deploy Prod
```

**✅ Checkpoint:** Understand the flow

#### Step 3.4: Configure Approvers
1. Go to CloudBees Unify Organization Settings
2. Go to Approvers
3. Add approver groups:
   - `qa-team`: Your email (for QA approvals)
   - `prod-approvers`: Your email (for Prod approvals)

**✅ Checkpoint:** Approvers configured

---

### **Day 3: First Orchestrated Release**

#### Step 3.5: Trigger Release
1. Make a small code change in backend or frontend
2. Commit and push to `main` branch
3. This automatically triggers Release Orchestration

**Watch the flow:**

**Stage 1: Deploy Dev (automatic)**
- ⏰ Duration: 2-3 minutes
- Updates dev-todo-app namespace
- Runs health checks
- Collects evidence

**✅ Checkpoint:** Dev deployment succeeds

**Stage 2: QA Approval Gate**
1. You'll receive notification (email or Unify UI)
2. Go to CloudBees Unify → Workflows → Release Orchestration
3. Click "Approve" for QA deployment

**Stage 3: Deploy QA**
- ⏰ Duration: 5-10 minutes
- Updates qa-todo-app namespace
- Runs smoke tests (Robot Framework)
- Collects evidence

**✅ Checkpoint:** QA deployment succeeds, smoke tests pass

---

### **Day 4: Production Deployment**

#### Step 3.6: Set Up Production Environment
```bash
cd infrastructure

# Deploy prod environment
./deploy.sh prod

# Verify
kubectl get all -n prod-todo-app
```

**✅ Checkpoint:** Prod environment running

#### Step 3.7: Approve Production Deployment
**Stage 4: Production Approval Gate**
1. Review evidence from QA deployment
2. In CloudBees Unify, click "Approve" for Production
3. Note: Requires evidence validation

**Stage 5: Deploy Production**
- ⏰ Duration: 5-10 minutes
- Updates prod-todo-app namespace
- Runs health checks
- Runs production smoke tests
- Collects evidence
- Sends Slack notification (if configured)

**✅ Checkpoint:** Production deployment succeeds!

---

### **Day 5: Verify Multi-Environment Setup**

#### Step 3.8: Check All Environments
```bash
# Dev
kubectl get all -n dev-todo-app

# QA
kubectl get all -n qa-todo-app

# Prod
kubectl get all -n prod-todo-app
```

**✅ Checkpoint:** All 3 environments running

#### Step 3.9: Test Each Environment
```bash
# Dev
curl https://dev-todo.cloudbees-unify.example.com/health

# QA
curl https://qa-todo.cloudbees-unify.example.com/health

# Prod
curl https://todo.cloudbees-unify.example.com/health
```

**✅ Checkpoint:** All environments healthy

---

### **Week 3 Summary**

**What You Accomplished:**
- ✅ Deployed QA environment
- ✅ Deployed Production environment
- ✅ Configured release orchestration
- ✅ Set up approval gates
- ✅ Completed first Dev → QA → Prod release
- ✅ Evidence collection working

**Next Week:** Security and DORA Metrics

---

## Week 4: Security & DORA Metrics

### **Day 1: Review Security Scans**

#### Step 4.1: View Security Findings
1. Go to CloudBees Unify
2. Navigate to Security Center
3. Review findings from:
   - SAST (Static Analysis)
   - SCA (Dependency Vulnerabilities)
   - Secret Scanning

**✅ Checkpoint:** Security findings visible

#### Step 4.2: Triage a Finding
1. Select a finding
2. Mark as:
   - False Positive
   - Accepted Risk
   - Fix Required
3. Add notes

**✅ Checkpoint:** Finding triaged

#### Step 4.3: Fix a Vulnerability
If SCA found a vulnerable dependency:
```bash
cd backend

# Update requirements.txt with patched version
# Example: Flask==3.0.0 → Flask==3.0.1

git add requirements.txt
git commit -m "Security: Update Flask to 3.0.1 (CVE-xxxx-xxxx)"
git push origin main
```

**✅ Checkpoint:** Vulnerability fixed, new scan shows resolution

---

### **Day 2: DORA Metrics Dashboard**

#### Step 4.4: Access DORA Metrics
1. Go to CloudBees Unify
2. Navigate to Analytics
3. Select DORA Metrics

**You should see:**
- **Deployment Frequency**: How often you deploy
- **Lead Time for Changes**: Commit → Production time
- **Mean Time to Recovery**: Recovery time from failures
- **Change Failure Rate**: % of failed deployments

**✅ Checkpoint:** DORA metrics visible

#### Step 4.5: Analyze Your Metrics
Based on your data over the past 3 weeks:

**Example Analysis:**
- Deployment Frequency: 15 deployments (5/week)
- Lead Time: 12 minutes (commit to dev)
- MTTR: Not yet measured (no failures)
- Change Failure Rate: 0% (all successful)

**✅ Checkpoint:** Understand your baseline metrics

---

### **Day 3: Optimize Lead Time**

#### Step 4.6: Improve CI/CD Speed
With Smart Tests enabled, track improvement:

**Before Smart Tests:**
- Unit tests: 8 minutes
- Total build: 12 minutes
- Lead time: 15 minutes

**After Smart Tests:**
- Unit tests: 3 minutes (62% faster!)
- Total build: 7 minutes
- Lead time: 10 minutes

**✅ Checkpoint:** Measurable improvement in lead time

#### Step 4.7: Review Smart Tests Analytics
1. Go to CloudBees Unify
2. Navigate to Smart Tests Analytics
3. View:
   - Tests run vs. tests skipped
   - Time savings per build
   - Confidence scores

**✅ Checkpoint:** Smart Tests showing 50-60% time savings

---

### **Day 4: Evidence and Compliance**

#### Step 4.8: Review Deployment Evidence
1. Go to CloudBees Unify → Evidence
2. For each deployment, verify:
   - Artifact versions
   - Test results
   - Security scan results
   - Approvals
   - Deployment timestamps

**✅ Checkpoint:** Complete evidence trail visible

#### Step 4.9: Export Evidence Report
1. Select a production deployment
2. Click "Export Evidence"
3. Download PDF or JSON
4. Review the report

**✅ Checkpoint:** Evidence report downloaded

---

### **Day 5: Final Review & Documentation**

#### Step 4.10: Create Runbook
Document your setup for team members:

```markdown
# Todo App Runbook

## Deploy to Dev
./infrastructure/deploy.sh dev

## Trigger Release
1. Push to main
2. Approve QA gate
3. Approve Prod gate

## Toggle Feature Flags
Cask UI: https://app.cask.io/...

## View DORA Metrics
CloudBees Unify → Analytics → DORA

## Emergency Rollback
kubectl rollout undo deployment/backend -n prod-todo-app
```

**✅ Checkpoint:** Runbook created

#### Step 4.11: Team Handoff
Prepare handoff materials:
- Architecture diagrams
- Repository links
- Access credentials
- Runbook
- Known issues

**✅ Checkpoint:** Documentation complete

---

### **Week 4 Summary**

**What You Accomplished:**
- ✅ Reviewed and triaged security findings
- ✅ Fixed vulnerabilities
- ✅ Accessed DORA metrics dashboard
- ✅ Measured baseline performance
- ✅ Verified 50-60% CI/CD improvement with Smart Tests
- ✅ Reviewed deployment evidence
- ✅ Created runbook and documentation

---

## 🎉 Congratulations!

You've completed the CloudBees Unify adoption journey!

### **What You've Mastered:**

✅ **CI/CD Automation**
- Multi-stage pipelines
- Automated testing
- Docker build and push

✅ **Smart Tests**
- AI-powered test subsetting
- 50-60% CI/CD time savings
- Observation and subsetting modes

✅ **Security**
- SAST, SCA, Secret scanning
- Vulnerability triage
- Security findings dashboard

✅ **Feature Management**
- Feature flag creation
- Real-time toggling
- No-deployment feature releases

✅ **Release Orchestration**
- Multi-environment deployment
- Approval gates
- Evidence collection

✅ **DORA Metrics**
- Deployment frequency tracking
- Lead time measurement
- Change failure rate monitoring

---

## Best Practices

### Smart Tests
1. **Run 5-10 commits in observation mode** before enabling subsetting
2. **Monitor confidence scores** - adjust if needed
3. **Review skipped tests** occasionally to ensure coverage
4. **Re-run observation** if you make major architectural changes

### Feature Flags
1. **Start with OFF by default** for new features
2. **Use progressive rollout** (10% → 50% → 100%)
3. **Monitor metrics** after enabling flags
4. **Clean up old flags** once features are stable

### Release Orchestration
1. **Always require approval for Prod**
2. **Run smoke tests in each environment**
3. **Collect evidence for compliance**
4. **Have a rollback plan ready**

### Security
1. **Never skip security scans**
2. **Triage findings within 24 hours**
3. **Fix critical vulnerabilities immediately**
4. **Track remediation time**

---

## Troubleshooting

### Smart Tests Not Subsetting
**Problem:** Still running all tests after switching to subsetting mode

**Solutions:**
- Verify 5-10 commits completed in observation mode
- Check `smart-tests-config.yaml` has `mode: subsetting`
- Review Smart Tests logs for errors
- Try lowering confidence threshold (e.g., 0.8)

---

### Feature Flags Not Updating
**Problem:** Frontend doesn't reflect flag changes

**Solutions:**
```bash
# Check ConfigMap
kubectl get configmap frontend-config -n dev-todo-app -o yaml

# Verify CASK_API_KEY is set
# Restart frontend
kubectl rollout restart deployment/frontend -n dev-todo-app

# Check frontend logs
kubectl logs deployment/frontend -n dev-todo-app
```

---

### Deployment Failing
**Problem:** Kubernetes deployment fails

**Solutions:**
```bash
# Check pod status
kubectl get pods -n dev-todo-app

# View pod logs
kubectl describe pod <pod-name> -n dev-todo-app
kubectl logs <pod-name> -n dev-todo-app

# Common issues:
# - Image pull errors: Check Docker credentials
# - CrashLoopBackOff: Check environment variables
# - Pending: Check resource limits
```

---

### Build Failing
**Problem:** CI/CD build fails

**Solutions:**
- Check workflow logs in CloudBees Unify
- Verify Docker credentials are correct
- Ensure tests pass locally first
- Check for dependency conflicts
- Review security scan findings

---

## Next Steps

### Expand Your Implementation

1. **Add More Features**
   - Implement pagination
   - Add search functionality
   - Create user profile pages

2. **Enhance Testing**
   - Add E2E tests with Selenium
   - Implement performance tests
   - Add chaos engineering tests

3. **Advanced Unify Features**
   - Set up Edge Runners
   - Implement custom actions
   - Create workflow templates

4. **Monitoring & Observability**
   - Integrate with Datadog/New Relic
   - Export metrics to Prometheus
   - Create custom dashboards

### Share Your Success

- Write a blog post about your experience
- Present to your team
- Contribute improvements back to the reference architecture

---

## Resources

- **CloudBees Unify Docs**: https://docs.cloudbees.com/docs/cloudbees-platform/
- **Smart Tests Guide**: https://docs.cloudbees.com/docs/cloudbees-platform/smart-tests
- **Feature Management**: https://docs.cloudbees.com/docs/cloudbees-feature-management/
- **GitHub Repositories**: https://github.com/tdesai2705/unify-ref-todo

---

**Project Team:**
- **Lead**: Xhesi Galanxhi
- **2-Tier App**: Tejas Desai
- **3-Tier App**: Dinesh Narlakanti
- **Infrastructure**: Anudeep Nalla

**CloudBees Unify Reference Architecture** | May 2026
