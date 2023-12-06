# Acceder à la diste des az disponible
data "aws_availability_zones" "available" {}

locals {
  azs = data.aws_availability_zones.available.names
}



# Creation du vpc

resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "project_vpc"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Creation du internet gateway 

resource "aws_internet_gateway" "project_internet_gateway" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project_vpc_igw"
  }
}

# Creation de la table de routage

resource "aws_route_table" "project_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project_public_rt"
  }
}

# Creation de la default route

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.project_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_internet_gateway.id
}

# Creation de la default route table

resource "aws_default_route_table" "project_private_rt" {
  default_route_table_id = aws_vpc.project_vpc.default_route_table_id

  tags = {
    Name = "project_private_rt"
  }
}

resource "aws_subnet" "project_public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.public_cidrs
  map_public_ip_on_launch = true
  #Chaque subnet est dans un AZ, si on veut une seule AZ on fait names[0]
  availability_zone = local.azs[0]

  tags = {
    Name = "project_public_subnet"
  }
}

resource "aws_subnet" "project_private_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.private_cidrs
  map_public_ip_on_launch = false
  #Chaque subnet est dans un AZ, si on veut une seule AZ on fait names[0]
  availability_zone = local.azs[0]

  tags = {
    Name = "project_private_subnet"
  }
}

resource "aws_route_table_association" "project_route_assoc" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.project_public_subnet.id
  route_table_id = aws_route_table.project_rt.id
}

resource "aws_security_group" "instances_sg" { 
  name        = "instances_sg"
  description = "Security group for instances"
  vpc_id      = aws_vpc.project_vpc.id

}

resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances_sg.id
}

resource "aws_security_group_rule" "engress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instances_sg.id
}

