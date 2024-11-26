resource "aws_cloudwatch_event_rule" "ebs_volume_check" {
  name        = "ebs_volume_checking"
  description = "ebs volume check"
  event_pattern = jsonencode({
  "source": ["aws.ec2"],
  "detail-type": ["EBS Volume Notification"],
  "detail": {
    "event": ["createVolume"]
  }
 })
}

resource "aws_cloudwatch_event_target" "lambda-function-target" {
  target_id = "ebs_volume_check"
  rule      = aws_cloudwatch_event_rule.ebs_volume_check.name
  arn       = aws_lambda_function.test_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ebs_volume_check.arn
}