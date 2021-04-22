data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.name}:*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${module.aws_s3_bucket_artifact_name.name}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:DescribeParameters",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParameter",
    ]

    resources = [
      "arn:aws:ssm:*:*:parameter/tvlk-secret/terraform-cicd/terraform-cicd/github-token",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrpyt",
    ]

    resources = [
      "arn:aws:kms:ap-southeast-1:${data.aws_caller_identity.current.account_id}:alias/aws/s3",
    ]
  }
}
