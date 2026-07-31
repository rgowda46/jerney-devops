# 🛤️ Jerney — Blog Platform

A modern full-stack blog platform built with a three-tier architecture featuring a React frontend, Node.js backend, and PostgreSQL database.

![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react)
![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=flat-square&logo=node.js)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat-square&logo=postgresql)

---

> [!IMPORTANT]
> **Looking for the full DevSecOps implementation?**
> Switch to the [`devops`](../../tree/devops) branch for Docker, Kubernetes (Amazon EKS), Terraform, AWS Load Balancer Controller, Amazon Route 53, deployment documentation, screenshots, and more.
>
> ```bash
> git checkout devops
> ```

---

## ✨ Features

- 📝 Create blog posts
- ✏️ Edit your existing posts
- 🗑️ Delete posts
- 💬 Comment on posts
- 🎨 Modern responsive UI

---

## 🏗️ Architecture

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────▶│   Backend    │────▶│ PostgreSQL   │
│   (React)    │◀────│ (Node.js +   │◀────│   Database   │
│              │     │  Express)    │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## 📁 Project Structure

```text
Jerney/
├── frontend/                # React frontend
├── backend/                 # Node.js Express API
├── deploy/                  # EC2 deployment scripts
├── screenshots/             # Project screenshots
├── JOURNAL.md               # Engineering journal
└── README.md
```

---

# 🚀 Deploy on AWS EC2

## Prerequisites

- AWS EC2 instance running **Ubuntu 22.04+**
- Security Group allowing inbound traffic on ports **22** (SSH) and **80** (HTTP)
- SSH access to the instance

## Step 1: Transfer the Code to EC2

```bash
scp -r -i your-key.pem ./Jerney ubuntu@<EC2_PUBLIC_IP>:~/Jerney
```

## Step 2: SSH into the Instance

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

## Step 3: Run the Setup Script

The `deploy/setup.sh` script installs everything and configures the application automatically.

```bash
cd ~/Jerney
chmod +x deploy/setup.sh
./deploy/setup.sh
```

The script will:

1. Update system packages
2. Install Node.js
3. Install PostgreSQL
4. Install Nginx
5. Install PM2
6. Create the database
7. Install backend dependencies
8. Build the React frontend
9. Configure Nginx as a reverse proxy
10. Start the backend with PM2

## Step 4: Access the Application

Open your browser:

```text
http://<EC2_PUBLIC_IP>
```

### Useful Commands

```bash
pm2 status
pm2 logs
pm2 restart all
sudo systemctl restart nginx
sudo -u postgres psql -d jerney_db
```

---

## 🧑‍💻 Local Development

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

```text
http://localhost:3000
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/posts` | Get all posts |
| GET | `/api/posts/:id` | Get single post with comments |
| POST | `/api/posts` | Create a new post |
| PUT | `/api/posts/:id` | Update a post |
| DELETE | `/api/posts/:id` | Delete a post |
| GET | `/api/comments/post/:postId` | Get comments for a post |
| POST | `/api/comments` | Create a comment |
| DELETE | `/api/comments/:id` | Delete a comment |

---

## 📖 Documentation

The complete engineering journey is documented in **`JOURNAL.md`**, covering:

- EC2 deployment
- Docker
- Docker Compose
- Terraform
- Kubernetes
- Amazon EKS
- AWS Load Balancer Controller
- Amazon Route 53
- Challenges and lessons learned

Project screenshots are available in the `screenshots/` directory.

---

## 🌿 Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Application source code with EC2 deployment |
| `docker` | Dockerized application using Docker and Docker Compose |
| `terraform` | AWS infrastructure provisioned with Terraform |
| `k8s` | Kubernetes deployment manifests for Minikube and Amazon EKS |
| `devops` | Complete DevSecOps implementation integrating Docker, Terraform, Kubernetes, Amazon EKS, AWS Load Balancer Controller, Route 53, and the application |

---

Built with ❤️ by **Rohith Gowda**.
