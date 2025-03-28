resource "aws_route_table" "public" {
  vpc_id = aws_vpc.csye6225_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.csye6225_igw.id
  }

  tags = {
    Name = "csye6225-public-route-table"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "csye6225-private-route-table"
  }
}
