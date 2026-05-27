output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "db_secret_arn" {
  description = "The ARN of the database credentials secret"
  value       = module.secrets.db_secret_arn
}

output "gemini_api_key_secret_arn" {
  description = "The ARN of the Gemini API key secret"
  value       = module.secrets.gemini_api_key_secret_arn
}
