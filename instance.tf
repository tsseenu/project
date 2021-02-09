locals {
  vpc_id           = "vpc-48897923"
  subnet_id        = "subnet-d9baf595"
  ssh_user         = "ec2-user"
  key_name         = "projectkey"
  private_key_path = "~/Downloads/projectkey.pem"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "apache" {
  name   = "apache_access"
  vpc_id = "vpc-48897923"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "apache" {
  ami                         = "ami-0a9d27a9f4f5c0efc"
  subnet_id                   = "subnet-d9baf595"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  security_groups             = [aws_security_group.apache.id]
  key_name                    = "projectkey"

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/Downloads/projectkey.pem")
      host        = aws_instance.apache.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.apache.public_ip}, --private-key ${"~/Downloads/projectkey.pem"} apache.yaml"
  }
}

output "apache_ip" {
  value = aws_instance.apache.public_ip
}
