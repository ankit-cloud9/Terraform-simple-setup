resource "aws_secretsmanager_secret" "new" {
  name = "project/dev/secret-v2"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "new_value" {
  secret_id = aws_secretsmanager_secret.new.id

  secret_string = jsonencode({
    rds_endpoint = aws_db_instance.rds.endpoint
    rds_username = var.db_username
    rds_password = random_password.db_password.result
  })
}
