resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "*"
      },
      {
        "Sid" : "AllowLambdaAccess",
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}


resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name        = "SendGridAPIKey-${replace(timestamp(), ":", "-")}"
  description = "SendGrid API Key for Lambda email functionality"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "sendgrid_api_key_version" {
  secret_id = aws_secretsmanager_secret.sendgrid_api_key.id
  secret_string = jsonencode({
    api_key = "***********************"
  })
}

resource "aws_lambda_function" "email_verification_lambda" {
  function_name = var.lambda_function_name
  runtime       = var.runtime
  handler       = var.lambda_handler
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = var.lambda_zip_path

  environment {
    variables = {
      SENDGRID_SECRET_NAME = aws_secretsmanager_secret.sendgrid_api_key.name
      BASE_URL             = var.BASE_URL
      email                = var.email
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}
