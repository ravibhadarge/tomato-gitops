resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "/tomato/${var.env}/db-credentials"
  description             = "Database credentials for the tomato ${var.env} environment"
  recovery_window_in_days = 0

  tags = {
    Name    = "/tomato/${var.env}/db-credentials"
    Env     = var.env
    Project = var.project
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
  })
}


