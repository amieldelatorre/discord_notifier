data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    condition {
      test      = "StringEquals"
      variable  = "aws:SourceAccount"
      values    = [ data.aws_caller_identity.current.account_id ]
    }
  }
}

data "aws_iam_policy_document" "scheduler_invoke_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      "${aws_lambda_function.discord_notifier.arn}",
      "${aws_lambda_function.discord_notifier.arn}:*"
    ]
  }
}

resource "aws_iam_policy" "discord_notifier_scheduler" {
  name        = "${local.lambda_function_name}-scheduler"
  path        = "/"
  description = "IAM policy for scheduler to invoke the lambda"
  policy      = data.aws_iam_policy_document.scheduler_invoke_lambda.json
}

resource "aws_iam_role" "scheduler" {
  name                = "${var.project_name}-scheduler"
  assume_role_policy  = data.aws_iam_policy_document.scheduler_assume_role.json
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.discord_notifier_scheduler.arn
}

resource "aws_scheduler_schedule" "discord_notifier" {
  name        = "${var.project_name}-scheduler"
  group_name  = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression           = "cron(30 11 */4 * ? *)"
  schedule_expression_timezone  = "Pacific/Auckland" 

  target {
    arn       = aws_lambda_function.discord_notifier.arn
    role_arn  = aws_iam_role.scheduler.arn
    input     = jsonencode(jsondecode(var.scheduler_input))
  }
}