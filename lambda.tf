data "archive_file" "python_lambda_package" {
  type = "zip"
  source_file = "./lambda_function.py"
  output_path = "ebs_check.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Define the IAM Policy that gives permissions to modify and delete EBS volumes
resource "aws_iam_policy" "lambda_ec2_permissions" {
  name        = "lambda_ec2_permissions"
  description = "Allow Lambda to modify and delete EC2 volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:ModifyVolume",
        "ec2:DeleteVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_ec2_permissions.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "ebs_check.zip"
  function_name = "ebs_volume_check"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  runtime = "python3.13"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  retention_in_days = 3  # Set the retention period (e.g., 7 days)
}

# permission of writing logs to the log group is given to lambda by attaching it to lambda role
resource "aws_iam_role_policy" "lambda_log_policy" {
  name   = "lambda_log_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_lambda_function.test_lambda.function_name}:*"
    }
  ]
}
EOF
}
