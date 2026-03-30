terraform {
  required_providers {
    railway = {
      source  = "terraform-community-providers/railway"
      version = "0.6.1"
    }
  }
}

provider "railway" {
  token = var.railway_token
}

resource "railway_project" "openclaw" {
  name        = var.project_name
  description = "OpenClaw personal AI assistant"
  private     = true
}

resource "railway_service" "gateway" {
  name               = "openclaw-gateway"
  project_id         = railway_project.openclaw.id
  source_repo        = var.github_repo
  source_repo_branch = "main"
  root_directory     = "/"
  # Note: Region is managed via the Railway dashboard, not Terraform.
  # The provider cannot migrate regions on existing services.
  # Current region: us-west2 (set manually in dashboard)
  volume = {
    name       = "openclaw-data"
    mount_path = "/data"
  }
}

resource "railway_variable" "anthropic_api_key" {
  name       = "ANTHROPIC_API_KEY"
  value      = var.anthropic_api_key
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "openclaw_admin_password" {
  name       = "OPENCLAW_ADMIN_PASSWORD"
  value      = var.openclaw_admin_password
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "telegram_bot_token" {
  name       = "TELEGRAM_BOT_TOKEN"
  value      = var.telegram_bot_token
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "notion_api_key" {
  name       = "NOTION_API_KEY"
  value      = var.notion_api_key
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "google_client_id" {
  name       = "GOOGLE_CLIENT_ID"
  value      = var.google_client_id
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "google_client_secret" {
  name       = "GOOGLE_CLIENT_SECRET"
  value      = var.google_client_secret
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "google_refresh_token" {
  name       = "GOOGLE_REFRESH_TOKEN"
  value      = var.google_refresh_token
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "openclaw_gateway_token" {
  name       = "OPENCLAW_GATEWAY_TOKEN"
  value      = var.openclaw_gateway_token
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}

resource "railway_variable" "openclaw_port" {
  name       = "OPENCLAW_PORT"
  value      = var.openclaw_port
  environment_id = railway_project.openclaw.default_environment.id
  service_id     = railway_service.gateway.id
}
