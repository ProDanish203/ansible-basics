# General variables
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment for the application (e.g., dev, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prod", "dev", "test"], var.environment)
    error_message = "Environment must be one of 'prod', 'dev', or 'test'."
  }
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.123.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR block for the public subnet"
  type        = list(string)
  default     = ["10.123.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR block for the private subnet"
  type        = list(string)
  default     = ["10.123.4.0/24"]
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

# Compute
variable "ami" {
  description = "AMI ID for the instance"
  type        = string
  default     = "ami-02521d90e7410d9f0"
}

variable "instance_type" {
  description = "Type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "tf-key"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/tfkey.pub"
}
