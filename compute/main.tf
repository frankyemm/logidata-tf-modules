# ==========================================
# 1. AWS GLUE (Dominio Ventas)
# ==========================================
# Subimos los scripts a S3 para que Glue los pueda leer
resource "aws_s3_object" "script_b2s" {
  bucket = var.bronze_bucket_id
  key    = "scripts/sales/bronze_to_silver_sales.py"
  source = "../../src/domains/sales/bronze_to_silver_sales.py"
  etag   = filemd5("../../src/domains/sales/bronze_to_silver_sales.py")
}

resource "aws_s3_object" "script_s2g" {
  bucket = var.bronze_bucket_id
  key    = "scripts/sales/silver_to_gold_sales.py"
  source = "../../src/domains/sales/silver_to_gold_sales.py"
  etag   = filemd5("../../src/domains/sales/silver_to_gold_sales.py")
}

# Jobs de Glue configurados para soportar Delta Lake
resource "aws_glue_job" "b2s_sales" {
  name     = "${var.project_prefix}-${var.environment}-sales-bronze-to-silver"
  role_arn = var.glue_role_arn
  command {
    name            = "glueetl"
    script_location = "s3://${var.bronze_bucket_id}/${aws_s3_object.script_b2s.key}"
    python_version  = "3"
  }
  default_arguments = {
    "--datalake-formats" = "delta"
    "--conf"             = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
  }
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
}

resource "aws_glue_job" "s2g_sales" {
  name     = "${var.project_prefix}-${var.environment}-sales-silver-to-gold"
  role_arn = var.glue_role_arn
  command {
    name            = "glueetl"
    script_location = "s3://${var.bronze_bucket_id}/${aws_s3_object.script_s2g.key}"
    python_version  = "3"
  }
  default_arguments = {
    "--datalake-formats" = "delta"
    "--conf"             = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
  }
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
}

# ==========================================
# 2. AWS LAMBDA (Dominio Logística - IoT)
# ==========================================
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../src/domains/logistics/lambda_iot.py"
  output_path = "../../src/domains/logistics/lambda_iot.zip"
}

resource "aws_lambda_function" "iot_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_prefix}-${var.environment}-iot-processor"
  role             = var.lambda_role_arn
  handler          = "lambda_iot.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMO_TABLE = var.dynamo_table_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_trigger" {
  event_source_arn  = var.iot_stream_arn
  function_name     = aws_lambda_function.iot_processor.arn
  starting_position = "LATEST"
}
