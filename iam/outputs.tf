output "glue_role_arn" { value = aws_iam_role.glue_role.arn }
output "glue_role_name" { value = aws_iam_role.glue_role.name }
output "redshift_role_arn" { value = aws_iam_role.redshift_role.arn }
output "lambda_role_arn" { value = aws_iam_role.lambda_role.arn }
output "lambda_role_name" { value = aws_iam_role.lambda_role.name }
