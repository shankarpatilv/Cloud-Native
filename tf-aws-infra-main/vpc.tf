
resource "aws_vpc" "csye6225_vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.vpc_name
  }
}
