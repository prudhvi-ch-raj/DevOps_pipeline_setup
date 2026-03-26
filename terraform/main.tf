terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow-ssh-http"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami             = "ami-0abcdef1234567890"  # pick your ami
  instance_type   = var.vm_size
  key_name        = "your-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  subnet_id       = aws_subnet.public.id
  user_data       = <<EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
EOF

  tags = {
    Name = "sample-app-server"
  }
}

output "vm_public_ip" {
  value = aws_instance.app_server.public_ip
}
