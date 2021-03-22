locals {
  vpc_id           = "vpc-7b18ba10"
  subnet_id        = "subnet-1c3c3f66"
  ssh_user         = "ubuntu"
  key_name         = "myaws-terraform-ssh-key"
  private_key_path = "/home/abdoulaye/Desktop/myaws-terraform-ssh-key.pem"

}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "demo-ansible-terra" {

  name   = "ngix-sercurity"
  vpc_id = local.vpc_id

  ingress {
    description = "ingress from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ingress from VPC"
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

  tags = {
    Name = "allow-all"
  }
}
resource "aws_instance" "nginx" {
  ami                         = "ami-08962a4068733a2b6"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = local.subnet_id
  security_groups             = [aws_security_group.demo-ansible-terra.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]


    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yml"
  }

}

output "nginx-ip" {
  value = aws_instance.nginx.public_ip
}