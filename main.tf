resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support

  tags = merge(
    var.common_tags,
    {
    Name = var.project_name
    },
    var.vpc_tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
    Name = var.project_name
    },
    var.igw_tags
  )
}

# Public subnate
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]


  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-${local.azs[count.index]}"
  } 
   )
}

# Private subnate
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]


  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-${local.azs[count.index]}"
  } 
   )
}

# Database subnate
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]


  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database-${local.azs[count.index]}"
  } 
   )
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-public"
    },
    var.public_route_table_tags
  )
}

# Elastic IP 
resource "aws_eip" "eip" {
  domain   = "vpc"
  tags = {
    Name = "Roboshop-Elastic_ip"
  }
}

# Nat - Gateway 
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.nat_gateway_tags
    )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.main.id
  }
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-private"
    },
    var.private_route_table_tags
  )
}

# Database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.main.id
  }
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-database"
    },
    var.database_route_table_tags
  )
}

# Association of public route table with public subnets
# Public route table ---> public subnet 1a
# public route table ---> public subnet 1b
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# Association of private route table with private subnets
# Private route table ---> private subnet 1a
# private route table ---> private subnet 1b
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# Association of database route table with database subnets
# database route table ---> database subnet 1a
# database route table ---> database subnet 1b
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

# Database-subnet-group
resource "aws_db_subnet_group" "roboshop" {
  name       = var.project_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
       Name = var.project_name
    },
    var.db_subnet_group_tags
    )
}