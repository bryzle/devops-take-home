provider "aws" {
  region = "us-east-1"
}

# Get default VPC and subnet for simplicity
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "devops-takehome:latest"
}

# Security group for EC2 and ALB
resource "aws_security_group" "devops_sg_v2" {
  name        = "devops-sg-v2"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch template for EC2 instances
resource "aws_launch_template" "devops_v2" {
  name_prefix   = "devops-launch-template-v2-"
  image_id      = "ami-05c13eab67c5d8861"
  instance_type = "t2.micro"
  key_name      = "test"
  vpc_security_group_ids = [aws_security_group.devops_sg_v2.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
    docker run -d -p 8080:8080 ${var.docker_image}
  EOF
  )
}

# Application Load Balancer
resource "aws_lb" "devops_alb_v2" {
  name               = "devops-alb-v2"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.devops_sg_v2.id]
}



resource "aws_lb_target_group" "devops_tg_v2" {
  name     = "devops-tg-v2"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http_v2" {
  load_balancer_arn = aws_lb.devops_alb_v2.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devops_tg_v2.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "devops_asg_v2" {
  name                      = "devops-asg-v2"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = data.aws_subnets.default.ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.devops_tg_v2.arn]

  launch_template {
    id      = aws_launch_template.devops_v2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "DevOpsServer"
    propagate_at_launch = true
  }
}

variable "docker_image" {
  description = "Docker image to run"
}
