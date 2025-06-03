provider "aws" {
  region = "us-east-1"
}

# Security group for EC2 and ALB
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access for load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH for management (optional)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }
  # Egress (outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get default VPC and subnet for simplicity
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "defaul_
