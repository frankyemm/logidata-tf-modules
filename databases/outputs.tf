output "postgres_endpoint" { value = aws_db_instance.postgres.endpoint }
output "redshift_endpoint" { value = aws_redshiftserverless_workgroup.warehouse.endpoint[0].address }
output "dynamodb_table_name" { value = aws_dynamodb_table.events.name }
output "dynamodb_table_arn" { value = aws_dynamodb_table.events.arn }
