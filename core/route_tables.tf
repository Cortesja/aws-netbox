###################
# Route table
###################

# All public subnets > internet
resource "aws_route_table" "public" {
  vpc_id        = aws_vpc.netbox_vpc.id

  route {
    cidr_block  = "0.0.0.0/0" # Destination
    gateway_id  = aws_internet_gateway.igw.id # Target
  }

  tags = { Name = "public-igw" }
}

# Private subnets > NAT
resource "aws_route_table" "private" {
  vpc_id          = aws_vpc.netbox_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.ngw.id
  }

  tags = { Name = "private-ngw" }
}

#####################
# Associations
#####################

resource "aws_route_table_association" "public_1" {
  subnet_id       = aws_subnet.public[0].id
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id       = aws_subnet.public[1].id
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id       = aws_subnet.private[0].id
  route_table_id  = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id       = aws_subnet.private[1].id
  route_table_id  = aws_route_table.private.id
}
