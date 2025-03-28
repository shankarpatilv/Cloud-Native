resource "aws_route_table_association" "public_subnet_association" {
  for_each       = { for key, subnet in aws_subnet.subnets : key => subnet if subnet.tags["Type"] == "public" }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = { for key, subnet in aws_subnet.subnets : key => subnet if subnet.tags["Type"] == "private" }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
