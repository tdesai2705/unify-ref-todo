# CloudBees Unify Reference Architecture - 2-Tier To-Do Application

This is the parent repository that orchestrates all components of the 2-tier to-do application.

## Repository Structure (8 Repositories)

### 1. **unify-ref-todo** (This repo - Parent/Orchestrator)
Parent repository managing all submodules via Git submodules.

### 2. **backend/** - REST API Service
- **Tech Stack**: Python Flask, SQLAlchemy ORM
- **Port**: 5000
- **Responsibility**: Business logic, API endpoints, database interaction

### 3. **frontend/** - Web UI
- **Tech Stack**: Python Flask, Jinja2 templates, CSS/JS
- **Port**: 5001
- **Responsibility**: Server-side rendering, user interface

### 4. **database/** - Database Schemas
- **Tech Stack**: PostgreSQL 15
- **Contents**: SQL schemas, migration scripts, seed data

### 5. **tests-unit/** - Unit Tests
- **Tech Stack**: pytest
- **Coverage**: Backend API unit tests (8+ test functions)

### 6. **tests-integration/** - Integration Tests
- **Tech Stack**: Robot Framework
- **Coverage**: API integration tests (6+ test cases)

### 7. **infrastructure/** - Infrastructure as Code
- **Tech Stack**: Kubernetes manifests, Helm charts
- **Contents**: Deployments, Services, ConfigMaps, Secrets, Ingress

### 8. **workflows/** - CI/CD Workflows
- **Tech Stack**: CloudBees Unify workflows (YAML)
- **Contents**: Build, test, security scan, deploy pipelines

## Quick Start

```bash
# Clone with all submodules
git clone --recursive https://github.com/tdesai2705/unify-ref-todo.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│           2-Tier Architecture                   │
├─────────────────────────────────────────────────┤
│  TIER 1: Web Application                       │
│  ├── Frontend (Flask + Jinja2) - Port 5001     │
│  └── Backend (Flask REST API) - Port 5000      │
├─────────────────────────────────────────────────┤
│  TIER 2: Database                              │
│  └── PostgreSQL 15 - Port 5432                 │
└─────────────────────────────────────────────────┘
```

## CloudBees Unify Features

This reference architecture demonstrates:
- ✅ CI/CD Workflows (Build, Test, Deploy)
- ✅ Smart Tests (Intelligent test subsetting)
- ✅ Security Scanning (SAST, SCA, Secrets)
- ✅ Feature Management (Cask - feature flags)
- ✅ Release Orchestration (Dev → QA → Prod)
- ✅ DORA Metrics & Analytics
- ✅ Multi-environment deployment

## Project Context

- **Lead**: Xhesi Galanxhi
- **Team**: Tejas Desai (2-tier), Dinesh Narlakanti (3-tier), Anudeep Nalla (Infrastructure)
- **Duration**: 8 weeks
- **Purpose**: Knowledge transfer and enterprise reference architecture

## Getting Started

See individual submodule READMEs for detailed setup instructions:
- [Backend Setup](backend/README.md)
- [Frontend Setup](frontend/README.md)
- [Database Setup](database/README.md)
- [Infrastructure Setup](infrastructure/README.md)

---

**Status**: Day 2 - Repository structure created
**Next**: Populate submodules with application code
