# ==========================================
# 1. ROL PARA AWS GLUE (ETL)
# ==========================================
resource "aws_iam_role" "glue_role" {
  name = "${var.project_prefix}-${var.environment}-glue-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "glue.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "glue_s3_strict_policy" {
  name        = "${var.project_prefix}-${var.environment}-glue-s3-policy"
  description = "Permisos estrictos de S3 para Glue"
  policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = flatten([
        for arn in var.datalake_bucket_arns : [arn, "${arn}/*"]
      ])
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_strict_policy.arn
}

# ==========================================
# 2. ROL PARA REDSHIFT SERVERLESS
# ==========================================
resource "aws_iam_role" "redshift_role" {
  name = "${var.project_prefix}-${var.environment}-redshift-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "redshift.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_readonly" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# ==========================================
# 3. ROL PARA LAMBDA (Streaming IoT)
# ==========================================
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_prefix}-${var.environment}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permiso gestionado por AWS para que Lambda pueda leer el Stream de Kinesis
resource "aws_iam_role_policy_attachment" "lambda_kinesis_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

# Permiso estricto (PoLP) para escribir en DynamoDB usando un ARN predictivo (Evita dependencia circular)
resource "aws_iam_policy" "lambda_dynamo_strict_policy" {
  name        = "${var.project_prefix}-${var.environment}-lambda-dynamo-policy"
  description = "Permisos estrictos para insertar en DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["dynamodb:PutItem"]
        # Construimos el ARN usando el formato estándar de AWS porque sabemos cómo se llama la tabla
        Resource = "arn:aws:dynamodb:*:*:table/${var.project_prefix}-${var.environment}-events"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_strict_policy.arn
}
