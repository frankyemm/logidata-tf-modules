variable "project_prefix" {
  description = "Prefijo para los recursos (ej. logidata)"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, qa, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  description = "IP del desarrollador para abrir el Security Group"
  type        = string
}
