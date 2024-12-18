# resource "aws_cloudwatch_metric_alarm" "ecs_pending_tasks" {
#   alarm_name          = "${terraform.workspace}-ecs-pending-tasks"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "PendingTaskCount"
#   namespace           = "AWS/ECS"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "0"
#   alarm_description   = "Alarm when there are pending ECS tasks"

#   dimensions = {
#     ClusterName = aws_ecs_cluster.main.name
#   }

#   alarm_actions = [aws_autoscaling_policy.scale_out.arn]
# }



# CloudWatch Event Rule (runs every minute)
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "${local.core_name_prefix}-trigger-every-minute"
  description         = "Trigger Lambda function every minute"
  schedule_expression = "rate(1 minute)"
}

# CloudWatch Event Target (points to Lambda)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.withLayerLambda.arn
}

# Lambda permission to allow CloudWatch Events to invoke the function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.withLayerLambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}