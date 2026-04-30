resource "aws_secretsmanager_secret" "main" {
  name = "project/dev/main-secret"
}

resource "aws_secretsmanager_secret_version" "main_value" {
  secret_id = aws_secretsmanager_secret.main.id

  secret_string = jsonencode({
    rds_endpoint = aws_db_instance.rds.endpoint
    rds_username = var.db_username
    rds_password = random_password.db_password.result
  })
}