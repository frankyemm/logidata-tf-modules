variable "project_prefix" { type = string }
variable "environment" { type = string }
variable "glue_role_arn" { type = string }
variable "lambda_role_arn" { type = string }
variable "bronze_bucket_id" { type = string }
variable "iot_stream_arn" { type = string }
variable "dynamo_table_name" { type = string }

variable "script_sales_b2s_path" {
  description = "Ruta local del script bronze to silver"
  type        = string
}

variable "script_sales_s2g_path" {
  description = "Ruta local del script silver to gold"
  type        = string
}

variable "script_logistics_lambda_path" {
  description = "Ruta local del código de la lambda IoT"
  type        = string
}
