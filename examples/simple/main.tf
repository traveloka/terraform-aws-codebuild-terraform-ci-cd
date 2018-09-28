provider "aws" {
  region = "ap-southeast-1"
}

module "terraform_ci_cd" {
  source            = "../.."
  terraform_version = "0.11.8"
  product_domain    = "beii"
  environment       = "staging"

  source_repository_url = "https://github.com/traveloka/terraform-aws-cicd-test.git"
}
