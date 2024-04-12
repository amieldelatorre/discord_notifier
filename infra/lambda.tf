locals {
  lambda_function_name = "${var.project_name}"
}

resource "aws_cloudwatch_log_group" "discord_notifier" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "discord_notifier_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.discord_notifier.arn}:*"]
  }
}

resource "aws_iam_policy" "discord_notifier_logging" {
  name        = "${local.lambda_function_name}-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.discord_notifier_logging.json
}

data "aws_iam_policy_document" "discord_notifier_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "discord_notifier" {
  name                = "${var.project_name}-lambda"
  assume_role_policy  = data.aws_iam_policy_document.discord_notifier_assume_role.json
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.discord_notifier.name
  policy_arn = aws_iam_policy.discord_notifier_logging.arn
}

data "local_file" "lambda_function_zip" {
  filename = "../${var.lambda_function_zip_filename}"
}

resource "aws_lambda_function" "discord_notifier" {
  function_name     = local.lambda_function_name
  role              = aws_iam_role.discord_notifier.arn
  filename          = data.local_file.lambda_function_zip.filename
  handler           = "bootstrap"
  runtime           = "provided.al2023"
  source_code_hash  = data.local_file.lambda_function_zip.content_base64sha512

  depends_on = [ 
    aws_cloudwatch_log_group.discord_notifier,
    aws_iam_role.discord_notifier,
    aws_iam_role_policy_attachment.logging
   ]
}