#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible playbook is not installed. Please install it first."
        exit 1
    fi
    
    print_status "All requirements satisfied."
}

# Generate SSH key if it doesn't exist
generate_ssh_key() {
    if [ ! -f ~/.ssh/tfkey ]; then
        print_status "Generating SSH key pair..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/tfkey -N "" -C "terraform-key"
        chmod 600 ~/.ssh/tfkey
        chmod 644 ~/.ssh/tfkey.pub
        print_status "SSH key pair generated successfully."
    else
        print_status "SSH key pair already exists."
    fi
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Validate configuration
    terraform validate
    
    # Plan deployment
    terraform plan -var="app_name=nextjs-demo"
    
    # Apply configuration
    terraform apply -var="app_name=nextjs-demo" -auto-approve
    
    # Get outputs
    INSTANCE_IP=$(terraform output -raw instance_ip)
    print_status "Infrastructure deployed successfully. Instance IP: $INSTANCE_IP"
    
    cd ..
}

# Deploy application with Ansible
deploy_application() {
    print_status "Deploying application with Ansible..."
    
    cd ansible
    
    # Wait for instance to be ready
    print_status "Waiting for instance to be ready..."
    sleep 30
    
    # Test SSH connection
    print_status "Testing SSH connection..."
    ansible all -i inventories/hosts.yaml -m ping --ssh-extra-args="-o StrictHostKeyChecking=no"
    
    # Run deployment playbook
    print_status "Running deployment playbook..."
    ansible-playbook -i inventories/hosts.yaml main.ansible.yaml --ssh-extra-args="-o StrictHostKeyChecking=no"
    
    cd ..
}

# Main deployment function
main() {
    print_status "Starting deployment process..."
    
    check_requirements
    generate_ssh_key
    deploy_infrastructure
    deploy_application
    
    print_status "Deployment completed successfully!"
    print_status "Your application should be accessible at: http://$(cd terraform && terraform output -raw instance_ip)"
}

# Run main function
main "$@"
