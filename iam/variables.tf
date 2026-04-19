variable "project_prefix" { type = string }
variable "environment" { type = string }
variable "datalake_bucket_arns" {
  description = "Lista de ARNs de los buckets del Data Lake para dar permisos a Glue"
  type        = list(string)
}
