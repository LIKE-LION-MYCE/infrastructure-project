# Outputs for IAM module

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.myce_ec2_role.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.myce_ec2_role.name
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.myce_ec2_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.myce_ec2_profile.arn
}

output "ssm_policy_arn" {
  description = "ARN of the SSM access policy"
  value       = aws_iam_policy.myce_ssm_access.arn
}