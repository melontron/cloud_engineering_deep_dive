data "archive_file" "axios_layer" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/with_layer/layer"
  output_path = "${path.module}/../src/lambdas/with_layer/dist/layer.zip"
}

data "archive_file" "with_layer_lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambdas/with_layer/src"
  output_path = "${path.module}/../src/lambdas/with_layer/dist/function.zip"
}

resource "aws_lambda_layer_version" "axios_layer" {
  filename            = data.archive_file.axios_layer.output_path
  layer_name          = "axios-layer"
  compatible_runtimes = ["nodejs20.x"]

  source_code_hash = data.archive_file.axios_layer.output_base64sha256
}

resource "aws_lambda_function" "withLayerLambda" {
  filename      = data.archive_file.with_layer_lambda_function.output_path
  function_name = "withLayerLambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  layers        = [aws_lambda_layer_version.axios_layer.arn]

  source_code_hash = data.archive_file.with_layer_lambda_function.output_base64sha256
}


resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.lambda_queue.arn
  function_name    = aws_lambda_function.withLayerLambda.arn
  batch_size       = 1
  enabled          = true
}