resource "aws_internet_gateway" "csye6225_igw" {
  vpc_id = aws_vpc.csye6225_vpc.id

  tags = {
    Name = "csye6225-internet-gateway"
  }
}
