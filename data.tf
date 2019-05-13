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

######
# CI #
######
data "template_file" "ci_buildspec" {
  template = <<EOF
version: 0.2
phases:
  install:
    commands:
      - $${install_commands}
  pre_build:
    commands:
      - $${pre_build_commands}
  build:
    commands:
      - $${build_commands}
  post_build:
    commands:
      - $${post_build_commands}
EOF

  vars {
    install_commands = "${join("\n      - ", concat(local.ci_install_commands, var.ci_install_commands))}"

    pre_build_commands = "${join("\n      - ", concat(local.ci_pre_build_commands, var.ci_pre_build_commands))}"

    build_commands = "${join("\n      - ", concat(local.ci_build_commands, var.ci_build_commands))}"

    post_build_commands = "${join("\n      - ", concat(local.ci_post_build_commands, var.ci_post_build_commands))}"
  }
}

######
# CD #
######
data "template_file" "cd_buildspec" {
  template = <<EOF
version: 0.2
phases:
  install:
    commands:
      - $${install_commands}
  pre_build:
    commands:
      - $${pre_build_commands}
  build:
    commands:
      - $${build_commands}
  post_build:
    commands:
      - $${post_build_commands}
EOF

  vars {
    install_commands = "${join("\n      - ", concat(local.cd_install_commands, var.cd_install_commands))}"

    pre_build_commands = "${join("\n      - ", concat(local.cd_pre_build_commands, var.cd_pre_build_commands))}"

    build_commands = "${join("\n      - ", concat(local.cd_build_commands, var.cd_build_commands))}"

    post_build_commands = "${join("\n      - ", concat(local.cd_post_build_commands, var.cd_post_build_commands))}"
  }
}
