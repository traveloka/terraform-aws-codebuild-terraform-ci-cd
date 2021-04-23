locals {
  name = "${var.product_domain}-terraform-aws"

  #############
  # CI LOCALS #
  #############
  ci_install_commands = [
    //Set Environment Variables from Terraform module variables
    "export ARTIFACT_BUCKET=${module.aws_s3_bucket_artifact_name.name}",

    "export GITHUB_APP_ID=${var.github_app_id}",
    "export GITHUB_APP_INSTALLATION_ID=${var.github_app_installation_id}",
    "export TERRAFORM_VERSION=${var.terraform_version}",

    //Install Terraform
    ". install-terraform.sh",
  ]

  ci_pre_build_commands = [
    // Set env var OWNER_REPO, PR_ID, GIT_MASTER_COMMIT_ID,
    // GITHUB_TOKEN, GIT_ASKPASS, LATEST_COMMIT_APPLY
    ". ci-setup-env-var.sh",

    // Check CI prerequisites to do Terraform commands and set env var TF_WORKING_DIR
    ". ci-check.sh",
  ]

  ci_build_commands = [
    // Do Terraform Plan on TF_WORKING_DIR and store it on artifact folder
    ". ci-do-terraform-plan.sh",
  ]

  ci_post_build_commands = [
    // Create Plan Artifact
    ". ci-create-plan-artifact.sh",

    // Upload Plan Artifact to S3 Bucket
    ". ci-upload-plan-artifact.sh",

    // Notify Plan Artifact to Github Pull Request
    "ci-notify-plan-artifact-to-github-pr.py",
  ]

  #############
  # CD LOCALS #
  #############
  cd_install_commands = [
    //Set Environment Variables from Terraform module variables
    "export ARTIFACT_BUCKET=${module.aws_s3_bucket_artifact_name.name}",

    "export GITHUB_APP_ID=${var.github_app_id}",
    "export GITHUB_APP_INSTALLATION_ID=${var.github_app_installation_id}",
    "export TERRAFORM_VERSION=${var.terraform_version}",

    //Install Terraform
    ". install-terraform.sh",
  ]

  cd_pre_build_commands = [
    // Set env var OWNER_REPO, GIT_COMMIT_ID, GIT_MASTER_COMMIT_ID,
    // GITHUB_TOKEN, GIT_ASKPASS, PR_ID
    ". cd-setup-env-var.sh",

    // Get Plan Artifact based on GIT_MASTER_COMMIT_ID and PR_ID
    ". cd-get-plan-artifact.sh",
  ]

  cd_build_commands = [
    // Do Terraform Apply based on TF_WORKING_DIR and set TF_WORKING_DIR env var
    ". cd-do-terraform-apply.sh",
  ]

  cd_post_build_commands = [
    // Create Apply Artifact
    ". cd-create-apply-artifact.sh",

    // Upload Apply Artifact to S3 Bucket
    ". cd-upload-apply-artifact.sh",

    //Update latest-commit-apply on S3 Bucket
    ". cd-update-latest-commit-apply.sh",
  ]

  # CI Buildspec
  ci_buildspec = templatefile("${path.module}/ci_buildspec.tpl", {
    ci_shell            = var.ci_shell,
    install_commands    = join("\n      - ", concat(local.ci_install_commands, var.ci_install_commands)),
    pre_build_commands  = join("\n      - ", concat(local.ci_pre_build_commands, var.ci_pre_build_commands)),
    build_commands      = join("\n      - ", concat(local.ci_build_commands, var.ci_build_commands)),
    post_build_commands = join("\n      - ", concat(local.ci_post_build_commands, var.ci_post_build_commands)),
  })
  # CD Buildspec
  cd_buildspec = templatefile("${path.module}/cd_buildspec.tpl", {
    cd_shell            = var.cd_shell,
    install_commands    = join("\n      - ", concat(local.cd_install_commands, var.cd_install_commands)),
    pre_build_commands  = join("\n      - ", concat(local.cd_pre_build_commands, var.cd_pre_build_commands)),
    build_commands      = join("\n      - ", concat(local.cd_build_commands, var.cd_build_commands)),
    post_build_commands = join("\n      - ", concat(local.cd_post_build_commands, var.cd_post_build_commands))
  })
}

module "aws_s3_bucket_artifact_name" {
  source        = "github.com/traveloka/terraform-aws-resource-naming.git?ref=v0.19.1"
  name_prefix   = "${var.product_domain}-terraform-ci-cd-${data.aws_caller_identity.current.account_id}"
  resource_type = "s3_bucket"
}

resource "aws_s3_bucket" "artifact" {
  bucket = module.aws_s3_bucket_artifact_name.name
  acl    = "private"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    var.additional_tags,
    map("Name", local.name),
    map("ProductDomain", var.product_domain),
    map("Description", format("Artifact bucket for %s CodeBuild projects", local.name)),
    map("Environment", var.environment),
    map("ManagedBy", "terraform")
  )
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.artifact.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

######
# CI #
######
resource "aws_codebuild_project" "ci" {
  name          = "${local.name}-ci"
  description   = "Build project on ${var.product_domain} infra repository which run Terraform CI"
  service_role  = module.ci_codebuild_role.role_arn
  build_timeout = "60"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = var.image_credentials
    dynamic "environment_variable" {
      for_each = var.ci_env_var
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }

  }

  source {
    type                = "GITHUB"
    location            = var.source_repository_url
    buildspec           = local.ci_buildspec
    git_clone_depth     = 0
    report_build_status = true
  }

  tags = merge(
    var.additional_tags,
    map("ProductDomain", var.product_domain),
    map("Environment", var.environment),
    map("ManagedBy", "terraform")
  )
}

module "ci_codebuild_role" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v2.0.2"

  environment    = var.environment
  product_domain = var.product_domain

  role_identifier            = local.name
  role_description           = "Service Role for ${local.name}"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codebuild.amazonaws.com"
}

resource "aws_codebuild_webhook" "ci" {
  project_name = aws_codebuild_project.ci.name

  filter_group {
    # only build PRs
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED,PULL_REQUEST_UPDATED,PULL_REQUEST_REOPENED"
    }

    # only build PRs to master
    filter {
      type    = "BASE_REF"
      pattern = "refs/heads/master"
    }
  }
}

resource "aws_iam_role_policy" "ci_main" {
  name   = "${module.ci_codebuild_role.role_name}-main"
  role   = module.ci_codebuild_role.role_name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "ci_administrator_access" {
  role       = module.ci_codebuild_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ci_ecr" {
  role       = module.ci_codebuild_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

######
# CD #
######
resource "aws_codebuild_project" "cd" {
  name          = "${local.name}-cd"
  description   = "Build project on ${var.product_domain} infra repository which run Terraform CI"
  service_role  = module.cd_codebuild_role.role_arn
  build_timeout = "60"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = var.image_credentials

    dynamic "environment_variable" {
      for_each = var.cd_env_var
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }
  }

  source {
    type                = "GITHUB"
    location            = var.source_repository_url
    buildspec           = local.cd_buildspec
    git_clone_depth     = 0
    report_build_status = true
  }

  tags = merge(
    var.additional_tags,
    map("ProductDomain", var.product_domain),
    map("Environment", var.environment),
    map("ManagedBy", "terraform")
  )
}

module "cd_codebuild_role" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/service?ref=v2.0.2"

  environment    = var.environment
  product_domain = var.product_domain

  role_identifier            = local.name
  role_description           = "Service Role for ${local.name}"
  role_force_detach_policies = true
  role_max_session_duration  = 43200

  aws_service = "codebuild.amazonaws.com"
}

resource "aws_codebuild_webhook" "cd" {
  project_name = aws_codebuild_project.cd.name

  filter_group {
    # only build push events
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    # only build pushes to master
    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/master"
    }
  }
}

resource "aws_iam_role_policy" "cd_main" {
  name   = "${module.cd_codebuild_role.role_name}-main"
  role   = module.cd_codebuild_role.role_name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "cd_administrator_access" {
  role       = module.cd_codebuild_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
