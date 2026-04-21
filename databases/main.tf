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
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = true
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
}

# 4. Redshift Serverless (Data Warehouse)
resource "aws_redshiftserverless_namespace" "warehouse" {
  namespace_name      = "${var.project_prefix}-${var.environment}-namespace"
  db_name             = "analytics"
  admin_username      = "franky_admin"
  admin_user_password = var.db_password
  iam_roles           = [var.redshift_role_arn]
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
