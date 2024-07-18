resource "aws_vpc" "lab-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = var.cidr_public
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.lab-vpc.id
  cidr_block              = var.cidr_public1
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "Public1"
  }
}


resource "aws_route_table" "internet_route_table" {
  depends_on = [aws_internet_gateway.IGW]
  vpc_id     = aws_vpc.lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.lab-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_GW.id

  }

  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.internet_route_table.id
}
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.internet_route_table.id
}


resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.lab-vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_nat_gateway" "NAT_GW" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT_GW"
  }
  depends_on = [aws_internet_gateway.IGW]
}