resource "aws_vpc" "main" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "${var.app_name}-${var.environment}-public-subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-${var.environment}-public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-${var.environment}-sg"
  description = "Security group for ${var.app_name} in ${var.environment} environment"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "app_sg_ingress" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol       = "-1" # All protocols
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound traffic to the application security group"
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol       = "-1" # All protocols
  cidr_ipv4         = "0.0.0.0/0"
}