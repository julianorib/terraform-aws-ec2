terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
}

provider "aws" {
  # export AWS_ACCESS_KEY_ID="anaccesskey"
  # export AWS_SECRET_ACCESS_KEY="asecretkey"
  # export AWS_REGION="us-west-2"
}


resource "aws_vpc" "vpc" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_hostnames = true

  tags = local.common_tags
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = local.common_tags
}


resource "aws_subnet" "subnet_public_a" {
  vpc_id = aws_vpc.vpc.id
  # publica números impares
  cidr_block              = "10.200.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = local.common_tags
}

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = local.common_tags

}

resource "aws_route_table_association" "subnetpublic-a-to-routepublic" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.route_public.id
}

resource "aws_subnet" "subnet_private_a" {
  vpc_id = aws_vpc.vpc.id
  # private números pares
  cidr_block        = "10.200.2.0/24"
  availability_zone = "us-east-2a"

  tags = local.common_tags
}

resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.vpc.id

  route = []

  tags = local.common_tags

}

resource "aws_route_table_association" "subnetprivate-a-to-routeprivate" {
  subnet_id      = aws_subnet.subnet_private_a.id
  route_table_id = aws_route_table.route_private.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "virtual_machine" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.ssh_key.key_name
  subnet_id       = aws_subnet.subnet_public_a.id
  security_groups = [aws_security_group.acesso-out-internet.id, aws_security_group.acesso-in-ssh.id]
  count           = 2

  tags = {
    Name     = "${var.Name}-${count.index}"
    projeto  = var.Name
    ambiente = var.tag-ambiente
    dono     = var.tag-dono
    ccusto   = var.tag-ccusto
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("id_rsa.pub")

  tags = local.common_tags
}

resource "aws_security_group" "acesso-out-internet" {
  name        = "acesso-out-internet"
  description = "permite acesso out internet"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "acesso-in-ssh" {
  name        = "acesso-in-ssh"
  description = "permite acesso in ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "public_ip" {
  value = aws_instance.virtual_machine.*.public_ip

}