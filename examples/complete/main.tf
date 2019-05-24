provider "aws" {
  region = "ap-southeast-1"
}

module "terraform_ci_cd" {
  source            = "../.."
  terraform_version = "0.11.8"
  product_domain    = "beii"
  environment       = "staging"

  source_repository_url = "https://github.com/traveloka/terraform-aws-cicd-test.git"

  ci_env_var = [
    {
      "name" = "MY_SECRET",
      "value" = "MY_SECRET_VALUE"
    }, 
    {
      "name" = "MY_SECRET_2",
      "value" = "MY_SECRET_VALUE_2"
      "type" = "PARAMETER_STORE"
    }
  ]
  ci_install_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  ci_pre_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  ci_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  ci_post_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]

  cd_env_var = [
    {
      "name" = "MY_SECRET",
      "value" = "MY_SECRET_VALUE"
    }, 
    {
      "name" = "MY_SECRET_2",
      "value" = "MY_SECRET_VALUE_2"
      "type" = "PARAMETER_STORE"
    }
  ]
  cd_install_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  cd_pre_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  cd_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
  cd_post_build_commands = [
    "echo 'custom command 1'",
    "echo 'custom command 2'"
  ]
}
