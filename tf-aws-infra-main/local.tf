
locals {
  az_count = length(data.aws_availability_zones.available.names) >= 3 ? 3 : length(data.aws_availability_zones.available.names)

  subnets = flatten([
    for az_index in range(0, local.az_count) : [
      {
        name = format("public-subnet-%d", az_index),
        cidr = cidrsubnet(var.cidr, 4, az_index * 2),
        type = "public",
        az   = data.aws_availability_zones.available.names[az_index]
      },
      {
        name = format("private-subnet-%d", az_index),
        cidr = cidrsubnet(var.cidr, 4, az_index * 2 + 1),
        type = "private",
        az   = data.aws_availability_zones.available.names[az_index]
      }
    ]
  ])
}
