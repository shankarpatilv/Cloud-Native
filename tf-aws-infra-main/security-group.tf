resource "aws_security_group" "app_security_group" {
  name        = "application-security-group"
  description = "Allow inbound traffic for web applications"
  vpc_id      = aws_vpc.csye6225_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Allow custom TCP traffic for Flask"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"

    security_groups = [aws_security_group.lb_security_group.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ApplicationSecurityGroup"
  }
}
