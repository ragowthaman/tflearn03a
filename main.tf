
provider "aws" {
  region = var.aws_region
}


data "aws_ami" "latest_amazon2_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.os_image_name]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# security
resource "aws_security_group" "tflearn_sg" {
  name        = "tflearn_sg"
  description = "TF Learn 03 security group"
  vpc_id      = aws_vpc.tf_vpc01.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "web port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "web port"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tflearn_sg"
    "project" = "tf-learn03"
  }
}

# network
resource "aws_vpc" "tf_vpc01" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name: "tf-vpc01"
    "project": "tf-learn03"
  }
  
}

resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf_vpc01.id

  tags = {
    Name: "${var.env_prefix}-tf-igw"
    "project" = "tf-learn03"
  }  
}


resource "aws_route_table" "tf-rtbl" {
  vpc_id = aws_vpc.tf_vpc01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id

  } 

  tags = {
    Name: "${var.env_prefix}-tf-rtbl"
    "project" = "tf-learn03"
  }
}

resource "aws_nat_gateway" "tf-nat-gateway" {
  allocation_id = "eipalloc-0857817e3f1af756d"
  subnet_id = aws_subnet.tflearn_subnet02_pvt.id

  tags = {
    Name: "${var.env_prefix}-tf-natgw"
    "project" = "tf-learn03"
  }

  depends_on = [
    "aws_internet_gateway.tf-igw"
  ]
}


resource "aws_subnet" "tflearn_subnet01_pub" {
  vpc_id = aws_vpc.tf_vpc01.id
  cidr_block = var.subnet_cidr_block_pub

  tags = {
    Name= "${var.env_prefix}-tflearn_subnet01-pub",
    "project" = "tf-learn03"
  }
  
}


resource "aws_subnet" "tflearn_subnet02_pvt" {
  vpc_id = aws_vpc.tf_vpc01.id
  cidr_block = var.subnet_cidr_block_pvt

  tags = {
    Name = "${var.env_prefix}-tflearn-subnet02-pvt"
    "project" = "tf-learn03"
  }
}


resource "aws_instance" "webserver01" {
  ami = data.aws_ami.latest_amazon2_ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.tflearn_subnet01_pub.id
  # vpc_security_group_ids = ["aws_security_group.tflearn_sg.id"]
  #availability_zone = var.avail_zone
  associate_public_ip_address = false
  key_name = "gowthaman@kin_keypair"

  tags = {
    "project" = "tf-learn03"
    Name = "${var.env_prefix}-Webserver instances"
  }
}

