
resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key for EC2 encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
       
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}

EOF

}


resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  rotation_period_in_days = 90
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
        {
            "Sid": "AllowRootAccountAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "AllowRDSAccessViaS3Role",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/s3_management_role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowRDSAccessViaCloudWatchRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/cloudwatch_agent_role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowRDSAccess",
            "Effect": "Allow",
            "Principal": {
                "Service": "rds.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
     
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/s3_management_role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/s3_management_role"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}


  EOF


}

resource "aws_kms_key" "secrets_kms_key" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 30
  rotation_period_in_days = 90
  enable_key_rotation     = true
  policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Id": "kms-key-policy",
    "Statement": [
    {
            "Sid": "AllowRootAccountToManageKey",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
   
        {
            "Sid": "Allow service-linked role use of the customer managed key",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.accountID}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
            },
            "Action": [
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": true
                }
            }
        }
    ]
}

EOF

}
