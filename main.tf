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


resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gw"
  }
}


resource "aws_subnet" "my_subnet_public" {
  vpc_id = aws_vpc.my_vpc.id
  # publica números impares
  cidr_block        = "10.200.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet_public"
  }
}

resource "aws_route_table" "my_route_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "my_route_public"
  }

}

resource "aws_route_table_association" "subnetpublic-to-routepublic" {
  subnet_id      = aws_subnet.my_subnet_public.id
  route_table_id = aws_route_table.my_route_public.id
}

resource "aws_subnet" "my_subnet_private" {
  vpc_id = aws_vpc.my_vpc.id
  # private números pares
  cidr_block        = "10.200.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "my_subnet_private"
  }
}

resource "aws_route_table" "my_route_private" {
  vpc_id = aws_vpc.my_vpc.id

  route = []

  tags = {
    Name = "my_route_private"
  }

}

resource "aws_route_table_association" "subnetprivate-to-routeprivate" {
  subnet_id      = aws_subnet.my_subnet_private.id
  route_table_id = aws_route_table.my_route_private.id
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

resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name
  subnet_id     = aws_subnet.my_subnet_public.id
  security_groups = [ aws_security_group.acesso-out-internet.id,aws_security_group.acesso-in-ssh.id ]

  tags = {
    Name = "myEC2"
  }
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("../mykey.pub")
}

resource "aws_security_group" "acesso-out-internet" {
  name = "acesso-out-internet"
  description = "permite acesso out internet"
  vpc_id = aws_vpc.my_vpc.id

  egress {
    description      = "all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "acesso-in-ssh" {
  name = "acesso-in-ssh"
  description = "permite acesso in ssh"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

output "public_ip" {
  value = aws_instance.myEC2.public_ip
  
}