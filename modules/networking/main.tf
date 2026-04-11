
# VPC

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets
  
  vpc_id = aws_vpc.myvpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key}"
  }
}

# routetable
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route to the internet
resource "aws_route" "public_internet_access" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myIgw.id
}

# public subnet association with IGW
resource "aws_route_table_association" "public" {
  for_each = var.public_subnets
  
  subnet_id = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}