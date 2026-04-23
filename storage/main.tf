locals {
  # Definimos las capas de la arquitectura Medallion
  layers = toset(["bronze", "silver", "gold"])
}

resource "aws_s3_bucket" "datalake" {
  for_each      = local.layers
  bucket        = "${var.project_prefix}-${var.environment}-${each.key}"
  force_destroy = true # Esencial para poder destruir el entorno MVP rápidamente

  tags = {
    Name        = "${var.project_prefix}-${var.environment}-${each.key}"
    Environment = var.environment
    Layer       = each.key
  }
}

# Bloqueo de acceso público aplicado a TODOS los buckets dinámicamente
resource "aws_s3_bucket_public_access_block" "datalake_block" {
  for_each = aws_s3_bucket.datalake

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cifrado AES256 por defecto para todas las capas del Lakehouse
resource "aws_s3_bucket_server_side_encryption_configuration" "datalake_encryption" {
  for_each = aws_s3_bucket.datalake

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
