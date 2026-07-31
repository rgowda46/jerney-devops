# 🚀 Jerney – Cloud-Native Blog Platform

A full-stack blog platform built with a modern three-tier architecture and deployed on AWS using Docker, Kubernetes, Terraform, Amazon EKS, and Route 53.

![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=flat-square&logo=node.js)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=flat-square&logo=terraform)
![Amazon EKS](https://img.shields.io/badge/Amazon-EKS-FF9900?style=flat-square&logo=amazonaws)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws)

---

## 📌 Overview

Jerney is a cloud-native blog platform demonstrating an end-to-end DevOps workflow—from local development to a production-ready deployment on Amazon Web Services.

The project includes:

- React frontend
- Node.js & Express backend
- PostgreSQL database
- Docker & Docker Compose
- Kubernetes
- Amazon EKS
- Terraform
- Amazon ECR
- AWS Load Balancer Controller
- Amazon EBS CSI Driver
- Amazon Route 53
- Helm

---

> [!IMPORTANT]
> **Looking for the full DevSecOps implementation?**
> Switch to the [`devops`](../../tree/devops) branch for Docker, Kubernetes (EKS Auto Mode), Terraform, CI/CD with GitHub Actions, container security scanning, and more.
>
> ```bash
> git checkout devops
> ```

---

# ✨ Features

- 📝 Create blog posts
- ✏️ Edit posts
- 🗑️ Delete posts
- 💬 Comment on posts
- 🎨 Modern React UI
- ⚡ REST API
- 🐘 PostgreSQL persistence
- 🐳 Dockerized services
- ☸️ Kubernetes deployments
- 🌍 Custom domain support

---

# 🏗️ Architecture

```text
                   Internet
                       │
               Amazon Route 53
                       │
        AWS Application Load Balancer
                       │
             Kubernetes Ingress
                       │
        ┌──────────────┴──────────────┐
        ▼                             ▼
 React Frontend Pods         Express Backend Pods
                                      │
                                      ▼
                             PostgreSQL Database
                                      │
                                      ▼
                          Amazon EBS Persistent Volume
```

---

# 🚀 DevOps Workflow

```text
Local Development
        │
        ▼
Dockerize Application
        │
        ▼
Docker Compose
        │
        ▼
Build Docker Images
        │
        ▼
Push Images to Amazon ECR
        │
        ▼
Provision AWS Infrastructure using Terraform
        │
        ▼
Create Amazon EKS Cluster
        │
        ▼
Deploy Kubernetes Resources
        │
        ▼
Install AWS Load Balancer Controller
        │
        ▼
Create ALB Ingress
        │
        ▼
Configure Amazon Route 53
        │
        ▼
Application Available via Custom Domain
```

---

# ⚙️ Technology Stack

## Application

- React
- Node.js
- Express
- PostgreSQL

## DevOps

- Docker
- Docker Compose
- Kubernetes
- Helm
- Terraform

## AWS Services

- Amazon EC2
- Amazon VPC
- Amazon ECR
- Amazon EKS
- Amazon EBS
- AWS Load Balancer Controller
- Amazon Route 53
- IAM
- CloudWatch

---

# 📁 Repository Structure

```text
.
├── backend/
├── frontend/
├── deploy/
├── docker/
├── k8s/
│   ├── eks/
│   ├── helm/
│   └── minikube/
├── terraform/
├── screenshots/
├── docs/
├── JOURNAL.md
└── README.md
```

---

# 🚀 Deployment Options

## Local Development

### Prerequisites

- Node.js 20+
- PostgreSQL 16+

### Backend

```bash
cd backend
npm install

export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=jerney_user
export DB_PASSWORD=jerney_pass_2026
export DB_NAME=jerney_db
export PORT=5000

npm start
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

The Vite development server runs on:

```
http://localhost:3000
```

---

## Docker

The project includes Dockerfiles for the frontend and backend, along with Docker Compose for local multi-container deployment.

```bash
docker compose up --build
```

---

## Kubernetes

Kubernetes manifests are available for:

- Minikube
- Amazon EKS
- Helm Charts

---

## Infrastructure as Code

Terraform provisions:

- VPC
- Public & Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Amazon EKS Cluster
- Managed Node Group

---

# 📡 REST API

| Method | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/health` | Health Check |
| GET | `/api/posts` | Get all posts |
| GET | `/api/posts/:id` | Get a single post |
| POST | `/api/posts` | Create a new post |
| PUT | `/api/posts/:id` | Update a post |
| DELETE | `/api/posts/:id` | Delete a post |
| GET | `/api/comments/post/:postId` | Get comments for a post |
| POST | `/api/comments` | Create a comment |
| DELETE | `/api/comments/:id` | Delete a comment |

---

# 📖 Documentation

A complete engineering journal documenting every phase of the project is available in:

```text
JOURNAL.md
```

The journal covers:

- Local deployment on EC2
- Docker
- Docker Compose
- Kubernetes
- Terraform
- Amazon EKS
- AWS Load Balancer Controller
- Route 53
- Troubleshooting
- Lessons learned

---

# 📸 Screenshots

The repository contains screenshots demonstrating:

- Local deployment
- Docker Compose
- Terraform provisioning
- Amazon EKS Cluster
- Kubernetes Resources
- AWS Application Load Balancer
- Route 53 Configuration
- Final deployed application

---

# ⚠️ Live Demo

The application was successfully deployed and validated on AWS using a custom domain.

To avoid unnecessary cloud infrastructure costs, the live environment has been intentionally torn down after validation.

---

---

# 🌿 Branch Strategy

| Branch | Purpose |
|---------|---------|
| `main` | Application source code with bare-metal deployment on AWS EC2 using Nginx, PM2, and PostgreSQL |
| `docker` | Containerized application using Docker and Docker Compose |
| `terraform` | Infrastructure as Code (IaC) for provisioning AWS resources including VPC, EKS, and networking |
| `k8s` | Kubernetes deployment manifests for Minikube and Amazon EKS, including Helm charts |
| `devops` | Complete end-to-end cloud-native solution integrating Docker, Terraform, Kubernetes, Amazon EKS, ALB Ingress, Route 53, and all application code |

---

Built with 💜 by **Rohith Gowda**.
