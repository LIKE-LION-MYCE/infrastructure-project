# Outputs for SSM Parameters Module
# These outputs show what was created, without exposing sensitive values

output "ssm_parameters_created" {
  description = "List of SSM parameter names created"
  value = [
    aws_ssm_parameter.db_url.name,
    aws_ssm_parameter.db_password.name,
    aws_ssm_parameter.db_username.name,
    aws_ssm_parameter.mongodb_uri.name,
    aws_ssm_parameter.redis_url.name,
    aws_ssm_parameter.jwt_secret.name,
    aws_ssm_parameter.aws_access_key_id.name,
    aws_ssm_parameter.aws_secret_access_key.name,
    aws_ssm_parameter.s3_bucket_name.name,
    aws_ssm_parameter.cloudfront_domain.name,
    aws_ssm_parameter.aws_region.name,
  ]
}

output "ssm_parameter_count" {
  description = "Total number of SSM parameters created"
  value       = length(local.all_parameters)
}

locals {
  all_parameters = [
    aws_ssm_parameter.db_url.name,
    aws_ssm_parameter.db_password.name,
    aws_ssm_parameter.db_username.name,
    aws_ssm_parameter.mongodb_uri.name,
    aws_ssm_parameter.redis_url.name,
    aws_ssm_parameter.jwt_secret.name,
    aws_ssm_parameter.aws_access_key_id.name,
    aws_ssm_parameter.aws_secret_access_key.name,
    aws_ssm_parameter.s3_bucket_name.name,
    aws_ssm_parameter.cloudfront_domain.name,
    aws_ssm_parameter.aws_region.name,
  ]
}