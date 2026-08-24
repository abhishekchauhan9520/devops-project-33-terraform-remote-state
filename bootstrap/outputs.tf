output "bucket_name" {
  value       = aws_s3_bucket.state.bucket
  description = "Terraform state bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "Terraform state bucket ARN"
}
