# Generación de contraseña segura de forma automática
resource "random_password" "db_pwd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+"
}

# Guardamos la contraseña en AWS Secrets Manager para auditoría
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${var.project_prefix}-${var.environment}-db-credentials"
  recovery_window_in_days = 0 # Para poder destruirlo rápido si haces terraform destroy
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "franky_admin"
    password = random_password.db_pwd.result
  })
}

# 1. Grupo de Subredes para las Bases de Datos
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_prefix}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = { Name = "${var.project_prefix}-${var.environment}-db-subnet-group" }
}

# 2. PostgreSQL (Legacy)
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_prefix}-${var.environment}-postgres"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "franky_admin"
  password               = random_password.db_pwd.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  storage_encrypted      = true
  skip_final_snapshot    = true
}

# 3. DynamoDB (Streaming IoT)
resource "aws_dynamodb_table" "events" {
  name         = "${var.project_prefix}-${var.environment}-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
  server_side_encryption {
    enabled = true
  }
}

# 4. Redshift Serverless (Data Warehouse)
resource "aws_redshiftserverless_namespace" "warehouse" {
  namespace_name       = "${var.project_prefix}-${var.environment}-namespace"
  db_name              = "analytics"
  admin_username       = "franky_admin"
  admin_user_password  = random_password.db_pwd.result
  iam_roles            = [var.redshift_role_arn]
  publicly_accesssible = false
}

resource "aws_redshiftserverless_workgroup" "warehouse" {
  depends_on          = [aws_redshiftserverless_namespace.warehouse]
  namespace_name      = aws_redshiftserverless_namespace.warehouse.namespace_name
  workgroup_name      = "${var.project_prefix}-${var.environment}-workgroup"
  base_capacity       = 8
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.db_security_group_id]
  publicly_accessible = true
}
