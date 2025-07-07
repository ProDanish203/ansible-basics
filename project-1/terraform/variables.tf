# General variables
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "nextjs-demo"
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
