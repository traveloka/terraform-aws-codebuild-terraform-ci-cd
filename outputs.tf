######
# CI #
######
output "ci_project_name" {
  value       = "${aws_codebuild_project.ci.name}"
  description = "The name of CI codebuild project"
}

output "ci_project_arn" {
  value       = "${aws_codebuild_project.ci.id}"
  description = "The ARN of CI codebuild project"
}

output "ci_buildspec" {
  value       = "${data.template_file.ci_buildspec.rendered}"
  description = "CI project's full generated buildspec"
}

output "ci_role_name" {
  value       = "${module.ci_codebuild_role.role_name}"
  description = "CI project's IAM role name"
}

######
# CD #
######
output "cd_project_name" {
  value       = "${aws_codebuild_project.cd.name}"
  description = "The name of CD codebuild project"
}

output "cd_project_arn" {
  value       = "${aws_codebuild_project.cd.id}"
  description = "The ARN of CD codebuild project"
}

output "cd_buildspec" {
  value       = "${data.template_file.cd_buildspec.rendered}"
  description = "CD project's full generated buildspec"
}

output "cd_role_name" {
  value       = "${module.cd_codebuild_role.role_name}"
  description = "CD project's IAM role name"
}
