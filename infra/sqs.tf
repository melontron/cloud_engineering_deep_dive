resource "aws_sqs_queue" "lambda_queue" {
  name                       = "${terraform.workspace}-lambda-queue"
  delay_seconds              = 0
  max_message_size           = 262144 # 256 KB
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30
}