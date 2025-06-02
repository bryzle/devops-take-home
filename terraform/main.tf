
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "devops_server" {
  ami           = "ami-05c13eab67c5d8861" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "test"
  tags = {
    Name = "DevOpsServer"
  }
   user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
    docker run -d -p 8080:8080 ${docker_image}
  EOF
  
}

variable "docker_image" {
  description = "Docker image to run"
}
