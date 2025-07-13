# AWS region for deployments
variable "aws_region" {
  description = "AWS region for deployments"
  type        = string
  default     = "us-east-1" # Set your preferred default region
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Name of the EC2 Key Pair
# This key pair must exist in your AWS account for SSH access.
variable "key_pair_name" {
  description = "Name of the EC2 Key Pair to use for the instance"
  type        = string
}

# Docker Hub username for pulling the application image
variable "docker_username" {
  description = "Docker Hub username for pulling the application image"
  type        = string
}

# Environment tag for resources (e.g., dev, prod)
variable "environment" {
  description = "Environment name for tagging resources"
  type        = string
  default     = "dev"
}