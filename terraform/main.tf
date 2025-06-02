
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

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "docker run -d -p 8080:8080 ${var.docker_image}"
    ]
  }

    connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
}

variable "docker_image" {
  description = "Docker image to run"
}
