provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["../aws_credentials/.aws"]
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch all public subnets in the default VPC
data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_security_group"
  description = "Allow inbound traffic on port 5000"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows all IP addresses
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Traffic
  ingress {
    description = "SSH from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "flask_sg"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform_key_pair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_instance" "flask_instance" {
  ami                         = "ami-0c94855ba95c71c99"  # Amazon Linux 2 AMI in us-east-1
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnets.default_public.ids[0]  # Select the first subnet
  key_name                    = aws_key_pair.generated_key.key_name
  user_data                   = file("./user_data.sh")

    # user_data = <<-EOF
    #           #!/bin/bash
    #           sudo yum update -y
    #           sudo yum install -y docker
    #           sudo usermod -a -G docker ec2-user
    #           id ec2-user
    #           # Reload a Linux user's group assignments to docker w/o logout
    #           newgrp docker
    #           wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
    #           sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
    #           sudo chmod -v +x /usr/local/bin/docker-compose
    #           sudo mv docker-compose-$( uname -s )-$( uname -m ) /usr/local/bin/docker-compose
    #           sudo chmod -v +x /usr/local/bin/docker-compose
    #           sudo systemctl enable docker.service
    #           sudo systemctl start docker.service
    #           sudo docker run -it --rm -d -p 5000:80 --name web nginx
    #           EOF



    provisioner "local-exec" {
      command = "echo $FOO $BAR $BAZ >> env_vars.txt"

      environment = {
        FOO = "bar"
        BAR = 1
        BAZ = "true"
      }
    }

  tags = {
    Name = "FlaskAppInstance"
  }
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.flask_instance.public_ip
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

#https://www.pluralsight.com/resources/blog/cloud/deploying-apps-terraform-aws