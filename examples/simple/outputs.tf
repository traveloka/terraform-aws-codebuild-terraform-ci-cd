output "artifact_s3_bucket_name" {
  value       = "${module.terraform_ci_cd.artifact_s3_bucket_name}"
  description = "The name of Artifact S3 Bucket"
}

output "ci_project_name" {
  value       = "${module.terraform_ci_cd.ci_project_name}"
  description = "The name of CI codebuild project"
}

output "ci_role_name" {
  value       = "${module.terraform_ci_cd.ci_role_name}"
  description = "CI project's IAM role name"
}

output "cd_project_name" {
  value       = "${module.terraform_ci_cd.cd_project_name}"
  description = "The name of CD codebuild project"
}

output "cd_role_name" {
  value       = "${module.terraform_ci_cd.cd_role_name}"
  description = "CD project's IAM role name"
}
