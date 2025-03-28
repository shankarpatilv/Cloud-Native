resource "aws_db_parameter_group" "db_param_group" {
  name        = "csye6225-db-param-group"
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL"

  parameter {
    name  = "max_connections"
    value = "150"
  }
}
