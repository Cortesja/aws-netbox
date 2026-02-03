###################
# Route table
###################

# ALl public subnets > internet
resource "aws_route_table" "public" {
  vpc_id        = aws_vpc.netbox-vpc.id

  route {
    cidr_block  = "0.0.0.0/0" # Destination
    gateway_id  = aws_internet_gateway.igw.id # Target
  }

  tags = { Name = "public-all-rt" }
}

# Private subnets > NAT
resource "aws_route_table" "private" {
  vpc_id          = aws_vpc.netbox-vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.ngw.id
  }

  tags = { Name = "private-to-NAT" }
}

#####################
# Associations
#####################

resource "aws_route_table_association" "public-1" {
  subnet_id       = aws_subnet.public-1.id
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id       = aws_subnet.public-2.id
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table_association" "private-1" {
  subnet_id       = aws_subnet.private-1.id
  route_table_id  = aws_route_table.private.id
}

resource "aws_route_table_association" "private-2" {
  subnet_id       = aws_subnet.private-2.id
  route_table_id  = aws_route_table.private.id
}
