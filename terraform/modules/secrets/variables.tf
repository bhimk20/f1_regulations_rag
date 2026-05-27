variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "db_username" {
  type        = string
  description = "Master username for database"
}

variable "gemini_api_key" {
  type        = string
  description = "Google Gemini API key"
  sensitive   = true
  default     = ""
}
