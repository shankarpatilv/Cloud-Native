
locals {
  public_subnet_id = [
    for subnet in aws_subnet.subnets :
    subnet.id if subnet.tags["Type"] == "public"
  ]
}

resource "aws_launch_template" "csye6225_asg" {
  name = "csye6225_asg"

  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.ssh_key

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_security_group.id]
    subnet_id                   = local.public_subnet_id[0]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.cloudwatch_agent_profile.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 10
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_kms_key.arn
    }
  }



  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update system
              sudo apt-get update -y

              sudo apt install -y awscli
 
              sudo apt install -y jq
              export AWS_DEFAULT_REGION=${var.aws_region}

              DB_CREDENTIALS=$(aws secretsmanager get-secret-value \
                --secret-id ${aws_secretsmanager_secret.rds_db_password.name}\
                --query 'SecretString' \
                --output text)

              DB_USERNAME=$(echo "$DB_CREDENTIALS" | jq -r '.username')
              DB_PASSWORD=$(echo "$DB_CREDENTIALS" | jq -r '.password')

              if [ -z "$DB_PASSWORD" ]; then
                echo "ERROR: Failed to retrieve DB_PASSWORD from Secrets Manager"
                exit 1
              fi


              cat <<EOL > /opt/webapp/.env
              DB_USERNAME=$DB_USERNAME
              DB_PASSWORD=$DB_PASSWORD
              DB_HOST=${aws_db_instance.rds_instance.address}
              DB_NAME=${var.DB_NAME}
              BUCKET_NAME=${aws_s3_bucket.Bucket-webapp.bucket}
              ACCOUNT_ID=${var.accountID}
              SNS_TOPIC_ARN=${aws_sns_topic.lambda_sns_topic.arn}
              EOL

              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/path/to/amazon-cloudwatch-agent.json -s
              
              sudo systemctl start app.service
              sudo systemctl start amazon-cloudwatch-agent
              EOF
  )

}


data "aws_route53_zone" "root_zone" {
  name         = "${var.route_name}.bannu.me"
  private_zone = false
}


resource "aws_route53_record" "web_app_a_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.web_app_alb.dns_name
    zone_id                = aws_lb.web_app_alb.zone_id
    evaluate_target_health = true
  }
}





