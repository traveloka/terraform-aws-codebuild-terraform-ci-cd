provider "aws" {
  region = "ap-southeast-1"
}

module "terraform_aws_codebuild" {
  source            = "../"
  terraform_version = "0.11.8"
  product_domain    = "bei"
  environment       = "staging"

  source_repository_url = "https://github.com/traveloka/terraform-aws-cicd-test.git"
}
