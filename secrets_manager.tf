resource "aws_secretsmanager_secret" "new_secret" {
  name = "new/secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "new" {
  secret_id = aws_secretsmanager_secret.new.id

  secret_string = jsonencode({
    rds_endpoint = aws_db_instance.rds.endpoint
    rds_username = var.db_username
    rds_password = random_password.db_password.result
  })
}
