resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!#$%^&*()-_=+[]{}<>?"
}

resource "aws_db_instance" "rds" {
  allocated_storage = 20
  engine            = "mysql"
  instance_class    = "db.t3.micro"

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  skip_final_snapshot = true
}
