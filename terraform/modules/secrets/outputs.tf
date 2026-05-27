output "db_secret_arn" {
  description = "The ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_secret_name" {
  description = "The name of the database credentials secret"
  value       = aws_secretsmanager_secret.db_secret.name
}

output "db_password" {
  description = "The generated database master password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "gemini_api_key_secret_arn" {
  description = "The ARN of the Gemini API key secret"
  value       = aws_secretsmanager_secret.gemini_secret.arn
}

output "gemini_api_key_secret_name" {
  description = "The name of the Gemini API key secret"
  value       = aws_secretsmanager_secret.gemini_secret.name
}
