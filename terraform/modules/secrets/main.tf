# Generate a secure random password for the RDS database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# DB Credentials Secret
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${var.project_name}-${var.environment}-db-credentials"
  description             = "Database credentials for F1 Regulations RAG"
  recovery_window_in_days = 0 # Force delete immediately on destroy for dev convenience

  tags = {
    Name = "${var.project_name}-${var.environment}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}

# Gemini API Key Secret
resource "aws_secretsmanager_secret" "gemini_secret" {
  name                    = "${var.project_name}-${var.environment}-gemini-api-key"
  description             = "Google Gemini API Key for RAG inference/embeddings"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-${var.environment}-gemini-api-key"
  }
}

resource "aws_secretsmanager_secret_version" "gemini_secret_val" {
  secret_id = aws_secretsmanager_secret.gemini_secret.id
  secret_string = jsonencode({
    api_key = var.gemini_api_key
  })
}
