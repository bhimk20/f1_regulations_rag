# Phase 1: Foundation (Networking & Secrets)

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
}

module "secrets" {
  source = "./modules/secrets"

  project_name   = var.project_name
  environment    = var.environment
  db_username    = var.db_username
  gemini_api_key = var.gemini_api_key
}
