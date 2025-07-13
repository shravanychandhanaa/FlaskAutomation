# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Data source to fetch the default VPC ID
# This ensures we use the existing default VPC without creating a new one.
data "aws_vpc" "default" {
  default = true
}

# Security Group for the Flask application
# Allows SSH (port 22) and HTTP (port 80) inbound traffic.
# It's associated with the dynamically fetched default VPC.
resource "aws_security_group" "app_security_group" {
  name        = "flask-app-security-group-${var.environment}"
  description = "Allow HTTP and SSH inbound traffic for Flask app"
  vpc_id      = data.aws_vpc.default.id # Use the ID of the default VPC

  # Ingress rule for SSH access (port 22)
  # In a production environment, restrict this to known IPs.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTP access (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "FlaskAppSG-${var.environment}"
    Environment = var.environment
  }
}

# EC2 Instance for the Flask application
# Uses the latest Amazon Linux 2 AMI and the security group defined above.
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name # Your existing EC2 key pair name

  # Associate with the security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  # User data script to bootstrap the EC2 instance:
  # 1. Update system packages.
  # 2. Install Docker.
  # 3. Start Docker service.
  # 4. Add ec2-user to the docker group.
  # 5. Enable Docker to start on boot.
  # 6. Pull the Docker image from Docker Hub.
  # 7. Run the Docker container, mapping port 80 (host) to 5000 (container).
  user_data = <<-EOF
    #!/bin/bash
echo "Starting user data script..."

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
echo "Docker installed and started."

sleep 10 # Give Docker a moment to fully start

# Pull the Docker image from Docker Hub
# IMPORTANT: Ensure this image name matches what's pushed by GitHub Actions
echo "Pulling Docker image ${var.docker_username}/my-flask-app:latest from Docker Hub..."
docker pull ${var.docker_username}/my-flask-app:latest
echo "Docker image pulled."

# Run the Docker container
echo "Running Docker container..."
docker run -d -p 80:5000 ${var.docker_username}/my-flask-app:latest
echo "Flask app container should be running."
EOF

  tags = {
    Name        = "FlaskAppServer-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
