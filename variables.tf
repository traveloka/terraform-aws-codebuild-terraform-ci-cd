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
  default     = "traveloka/codebuild-terraform-ci-cd-image:v0.1.2"
  description = "Docker image used by CodeBuild"
}

######
# CI #
######
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
