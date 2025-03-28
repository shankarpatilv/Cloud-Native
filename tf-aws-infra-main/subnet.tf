resource "aws_subnet" "subnets" {
  for_each = {
    for subnet in local.subnets :
    format("%s-%s", subnet.type, subnet.az) => subnet
  }

  vpc_id                  = aws_vpc.csye6225_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}

