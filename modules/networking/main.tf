# --- DATA SOURCES ---
data "aws_region" "current" {}

# Lookup existing VPC only if enabled
data "aws_vpc" "selected" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.existing_vpc_id
}

# Lookup existing subnets only if enabled
data "aws_subnets" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
}

# --- NETWORKING ---
resource "aws_vpc" "myvpc" {
  count                = var.use_existing_vpc ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "myIgw" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.myvpc[0].id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.use_existing_vpc ? {} : var.public_subnets
  
  vpc_id            = aws_vpc.myvpc[0].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key}"
  }
}

# Route table
resource "aws_route_table" "public" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.myvpc[0].id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw[0].id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# public subnet association
resource "aws_route_table_association" "public" {
  for_each = var.use_existing_vpc ? {} : aws_subnet.public
  
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}