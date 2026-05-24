variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name of the project used as prefix for resources"
  default     = "f1-regs-rag"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "model_provider" {
  type        = string
  description = "Inference model provider (bedrock or gemini)"
  default     = "bedrock"
  validation {
    condition     = contains(["bedrock", "gemini"], var.model_provider)
    error_message = "The model provider must be either 'bedrock' or 'gemini'."
  }
}

variable "embedding_provider" {
  type        = string
  description = "Embedding provider (bedrock or gemini)"
  default     = "bedrock"
  validation {
    condition     = contains(["bedrock", "gemini"], var.embedding_provider)
    error_message = "The embedding provider must be either 'bedrock' or 'gemini'."
  }
}

variable "bedrock_model_id" {
  type        = string
  description = "AWS Bedrock model ID for agent inference"
  default     = "amazon.nova-micro-v1:0"
}

variable "gemini_model_id" {
  type        = string
  description = "Gemini model ID for agent inference"
  default     = "gemini-2.0-flash"
}

variable "gemini_api_key" {
  type        = string
  description = "Google Gemini API key from AI Studio"
  sensitive   = true
  default     = ""
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "f1_regs_db"
}

variable "db_username" {
  type        = string
  description = "Master username for RDS PostgreSQL"
  default     = "postgres"
}
