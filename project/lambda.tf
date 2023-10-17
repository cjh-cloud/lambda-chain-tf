data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    effect = "Allow"

    actions = [
      "sqs:*",
      "logs:*",
      "xray:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "sqs" {
  name   = "sqs_permissions_${var.environment}"
  policy = data.aws_iam_policy_document.sqs.json
}

resource "aws_iam_role_policy_attachment" "sqs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.sqs.arn
}

# Lambda API

locals {
  lambda_api_zip = "lambda_api_function_payload.zip"
}

data "archive_file" "lambda_api" {
  type        = "zip"
  source_file = "lambda_api/main.py"
  output_path = local.lambda_api_zip
}

resource "aws_lambda_function_url" "lambda_api" {
  function_name      = aws_lambda_function.lambda_api.function_name
  authorization_type = "NONE"
}

output "lambda_api_url" {
  value = aws_lambda_function_url.lambda_api.function_url
}

resource "aws_lambda_function" "lambda_api" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = local.lambda_api_zip
  function_name    = "lambda_api_${var.environment}"
  handler          = "main.lambda_handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_api.output_base64sha256

  environment {
    variables = {
      foo        = "bar"
      queue_name = aws_sqs_queue.requests.name
    }
  }

  tracing_config {
    mode = "Active"
  }
}


### Proc lambda

locals {
  lambda_proc_zip = "lambda_proc_function_payload.zip"
}

data "archive_file" "lambda_proc" {
  type        = "zip"
  source_file = "lambda_proc/main.py"
  output_path = local.lambda_proc_zip
}

resource "aws_lambda_function" "lambda_proc" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = local.lambda_proc_zip
  function_name    = "lambda_proc_${var.environment}"
  handler          = "main.lambda_handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_proc.output_base64sha256

  environment {
    variables = {
      foo        = "bar"
      queue_name = aws_sqs_queue.requests.name
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.requests.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_proc.arn
  batch_size       = 1
}

# Cloudwatch logs
resource "aws_cloudwatch_log_group" "lambda_api" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_api.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_proc" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_proc.function_name}"
  retention_in_days = 30
}
