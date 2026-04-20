variable "project_prefix" { type = string }
variable "environment" { type = string }

# Variables de Red (vienen del módulo networking)
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "db_security_group_id" { type = string }

# Variables de Seguridad (vienen del módulo iam)
variable "redshift_role_arn" { type = string }

# Secretos
variable "db_password" {
  description = "Contraseña maestra para BDs"
  type        = string
  sensitive   = true
}
