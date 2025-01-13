# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "EKS-VPC"
  }

}

# Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true


  tags = {
    Name = "EKS-PublicSubnet-${count.index + 1}"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "EKS-PrivateSubnet-${count.index + 1}"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "EKS-IGW"
  }
}

# Elastic IPs for the NAT gatewaies, one eip per NAT gateway
resource "aws_eip" "nat_gw_eip" {
  count  = length(var.private_subnets)
  domain = "vpc"

  tags = {
    Name = "EKS-EIP-${count.index + 1}"
  }
}

# NAT gatewaies, each in a different public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  count         = length(var.public_subnets)

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "EKS-NGW-${count.index + 1}"
  }
}

# Route Table for the public subnets
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "EKS-Public-rtb"
  }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

# Route Tables for the private subnets, one route table for each private subnet
resource "aws_route_table" "private_rtb" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "EKS-Private-rtb-${count.index + 1}"
  }

}

# Associate each route table with the private subnet
resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}

# EKS Security Group
resource "aws_security_group" "eks_sg" {
  name   = var.eks_sg_name
  vpc_id = aws_vpc.vpc.id

  # Inbound Rule: Allow traffic from the Internet
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule: Allow all egress traffic
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = var.eks_sg_name
  }

}