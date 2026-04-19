output "bucket_ids" {
  value = { for k, v in aws_s3_bucket.datalake : k => v.id }
}

output "bucket_arns" {
  value = { for k, v in aws_s3_bucket.datalake : k => v.arn }
}
