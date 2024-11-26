data "archive_file" "simple_lambda" {
  type        = "zip"
  source_dir  = "../src/lambdas/simple/src/"
  output_path = "../src/lambdas/simple/dist/simple_lambda.zip"
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Security group for Lambda function"
  vpc_id      = aws_vpc.core.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "simple_lambda" {
  filename         = data.archive_file.simple_lambda.output_path
  function_name    = "simpleLambdaFunction"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.simple_lambda.output_base64sha256

  vpc_config {
    subnet_ids         = aws_subnet.core_private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

