variable "terraform_version" {
  type        = "string"
  description = "The terraform version which will be used"
}

variable "product_domain" {
  type        = "string"
  description = "The name of the product domain"
}

variable "environment" {
  type        = "string"
  description = "The environment which applied"
}

variable "additional_tags" {
  type        = "map"
  description = "Additional tags that will be added to the resources"
  default     = {}
}

variable "source_repository_url" {
  type        = "string"
  description = "The source repository URL"
}

variable "compute_type" {
  type        = "string"
  default     = "BUILD_GENERAL1_SMALL"
  description = "The builder instance class"
}

variable "image" {
  type        = "string"
  default     = "015110552125.dkr.ecr.ap-southeast-1.amazonaws.com/bei-codebuild-terraform-ci-cd-app:0.1.11"
  description = "Docker image used by CodeBuild"
}

variable "image_credentials" {
  type        = "string"
  default     = "SERVICE_ROLE"
  description = "Credentials to be used to pull codebuild environment image"
}

variable "github_app_id" {
  type        = "string"
  default     = "18429"
  description = "Terraform CI/CD Github App ID"
}

variable "github_app_installation_id" {
  type        = "string"
  default     = "7646288"
  description = "Terraform CI/CD Github App Installation ID"
}

######
# CI #
######
variable "ci_shell" {
  type        = "string"
  default     = "bash"
  description = "The shell command interpreter for CI"
}

variable "ci_env_var" {
  type = "list"

  default = []

  description = "Environment variables for CI"
}

variable "ci_install_commands" {
  type = "list"

  default = []

  description = "Commands for CI's install phase"
}

variable "ci_pre_build_commands" {
  type = "list"

  default = []

  description = "Commands for CI's pre_build phase"
}

variable "ci_build_commands" {
  type = "list"

  default = []

  description = "Commands for CI's build phase"
}

variable "ci_post_build_commands" {
  type = "list"

  default = []

  description = "Commands for CD's post_build phase"
}

######
# CD #
######
variable "cd_shell" {
  type        = "string"
  default     = "bash"
  description = "The shell command interpreter for CD"
}

variable "cd_env_var" {
  type = "list"

  default = []

  description = "Environment variables for CD"
}

variable "cd_install_commands" {
  type = "list"

  default = []

  description = "Commands for CD's install phase"
}

variable "cd_pre_build_commands" {
  type = "list"

  default = []

  description = "Commands for CD's pre_build phase"
}

variable "cd_build_commands" {
  type = "list"

  default = []

  description = "Commands for CD's build phase"
}

variable "cd_post_build_commands" {
  type = "list"

  default = []

  description = "Commands for CD's post_build phase"
}
