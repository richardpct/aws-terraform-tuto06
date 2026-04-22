data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my_vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw-${var.env}"
  }
}

resource "aws_subnet" "public_bastion" {
  count             = length(var.subnet_public_bastion)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_bastion[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_bastion-${var.env}"
  }
}

resource "aws_subnet" "public_web" {
  count             = length(var.subnet_public_web)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_public_web[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_public_web-${var.env}"
  }
}

resource "aws_subnet" "private_redis" {
  count             = length(var.subnet_private_redis)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_private_redis[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet_private_redis-${var.env}"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "custom_route-${var.env}"
  }
}

resource "aws_route_table_association" "public_bastion" {
  count          = length(var.subnet_public_bastion)
  subnet_id      = aws_subnet.public_bastion[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "public_web" {
  count          = length(var.subnet_public_web)
  subnet_id      = aws_subnet.public_web[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "eip_bastion-${var.env}"
  }
}

resource "aws_eip" "web" {
  domain = "vpc"

  tags = {
    Name = "eip_web-${var.env}"
  }
}
