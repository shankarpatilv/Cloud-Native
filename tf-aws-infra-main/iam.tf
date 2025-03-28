resource "aws_iam_role" "RoleS3" {
  name = "s3_management_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com",
          "AWS" : "arn:aws:iam::${var.accountID}:role/cloudwatch_agent_role"

        }
      }
    ]
  })
}

resource "aws_iam_policy" "PolicyS3" {
  name = "S3ManagementPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:HeadBucket",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutEncryptionConfiguration",
          "s3:PutLifecycleConfiguration"
        ],

        "Resource" : "*"
      },
      {

        "Effect" : "Allow",

        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.RoleS3.name
  policy_arn = aws_iam_policy.PolicyS3.arn
}
