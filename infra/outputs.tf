output "application_bucket_name" {
  value       = aws_s3_bucket.application.bucket
  description = "Sample application bucket managed by the remote-state-backed stack"
}

output "state_key_documentation" {
  value       = "Use team-infra/<environment>/terraform.tfstate for this configuration."
  description = "State separation convention"
}
