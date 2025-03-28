locals {
  private_subnet_id = [
    for subnet in aws_subnet.subnets :
    subnet.id if subnet.tags["Type"] == "private"
  ]
}

resource "aws_secretsmanager_secret" "rds_db_password" {
  name        = "RDSDatabasePassword-${replace(timestamp(), ":", "-")}"
  description = "Password for RDS instance"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
}

resource "random_password" "rds_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_secretsmanager_secret_version" "rds_db_password_version" {
  secret_id = aws_secretsmanager_secret.rds_db_password.id
  secret_string = jsonencode({
    username = "csye6225"
    password = random_password.rds_password.result
  })
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "csye6225-db-subnet-group"
  subnet_ids = local.private_subnet_id

  tags = {
    Name = "csye6225-db-subnet-group"
  }
}

resource "aws_db_instance" "rds_instance" {
  engine                 = "mysql"
  engine_version         = "8.0.39"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  multi_az               = false
  identifier             = "csye6225"
  username               = "csye6225"
  password               = jsondecode(aws_secretsmanager_secret_version.rds_db_password_version.secret_string)["password"]
  parameter_group_name   = aws_db_parameter_group.db_param_group.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  kms_key_id             = aws_kms_key.rds_kms_key.arn
  storage_encrypted      = true

  skip_final_snapshot = true
}



