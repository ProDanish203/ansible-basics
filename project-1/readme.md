# Next.js Application Deployment Guide

This guide provides complete instructions for deploying your Next.js application using Terraform for infrastructure and Ansible for configuration management.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   Terraform     │    │     AWS EC2     │
│   (Local)       │───▶│   (Infra)       │───▶│   (Instance)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                       ┌─────────────────┐              │
                       │    Ansible      │◀────────────┘
                       │ (Configuration) │
                       └─────────────────┘
                                │
                       ┌─────────────────┐
                       │   Docker +      │
                       │   Nginx +       │
                       │   Next.js App   │
                       └─────────────────┘
```

## 📋 Prerequisites

### Required Tools

- **Terraform** (>= 1.0)
- **Ansible** (>= 4.0)
- **Docker** (>= 20.0)
- **AWS CLI** (configured with your credentials)
- **SSH** client

### Setup Steps

1. **Install required tools:**

   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install terraform ansible awscli
   ```

2. **Configure AWS credentials:**

   ```bash
   aws configure
   ```

3. **Generate SSH key pair:**

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/tfkey -N ""
   ```

4. **Build your Docker image:**
   ```bash
   docker build -t nextjs-demo:latest .
   ```

## Quick Start

### Option 1: Using the Deployment Script (Recommended)

```bash
# Make the script executable
chmod +x deploy.sh

# Deploy with defaults
./deploy.sh

# Deploy with custom app name and environment
./deploy.sh myapp prod

# Destroy infrastructure
./destroy.sh
```

### Option 3: Manual Step-by-Step

1. **Deploy Infrastructure:**

   ```bash
   cd terraform
   terraform init
   terraform plan -var="app_name=nextjs-demo" -var="environment=dev"
   terraform apply -var="app_name=nextjs-demo" -var="environment=dev"
   ```

2. **Configure Application:**
   ```bash
   cd ansible
   ansible-playbook -i inventories/hosts.yml main.ansible.yaml
   ```

## 📁 Project Structure

```
project/
├── terraform/                 # Infrastructure as Code
│   ├── providers.tf
│   ├── variables.tf
|   ├── security.tf
│   ├── vpc.tf
│   ├── compute.tf
│   ├── outputs.tf
│   └── inventory-template.yaml
├── ansible/                   # Configuration Management
│   ├── main.ansible.yaml
│   ├── inventories/           # (auto-generated)
│   │   └── hosts.yaml
│   ├── group_vars/
│   │   └── all.yaml
│   └── roles/
│       ├── system/            # System setup
│       ├── docker/            # Docker installation
│       └── nginx/             # Web server setup
├── deploy.sh                  # Deployment script
├── destroy.sh                 # Destroy script
└── README-Deployment.md       # This file
```

## ⚙️ Configuration

### Terraform Variables

Edit `terraform/variables.tf` or pass variables during deployment:

```hcl
variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "nextjs-demo"
}

variable "environment" {
  description = "Environment (dev/test/prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free tier eligible
}
```

### Ansible Variables

Modify `ansible/group_vars/all.yml`:

```yaml
# Application Configuration
app_name: "nextjs-demo"
environment: "dev"
docker_image: "nextjs-demo:latest"
app_port: 3000
nginx_port: 80

# SSL Configuration
ssl_enabled: false
```

## 📝 Next Steps

1. **Set up CI/CD pipeline** with GitHub Actions or GitLab CI
2. **Configure monitoring** with CloudWatch or Prometheus
3. **Set up backup strategy** for application data
4. **Implement blue-green deployments** for zero-downtime updates
5. **Add auto-scaling** with Application Load Balancer