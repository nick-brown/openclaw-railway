variable "railway_token" {
  description = "Railway API token for authentication"
  type        = string
  sensitive   = true
}

variable "anthropic_api_key" {
  description = "Anthropic API key for Claude access"
  type        = string
  sensitive   = true
}

variable "openclaw_admin_password" {
  description = "Password for the OpenClaw admin dashboard"
  type        = string
  sensitive   = true
}

variable "telegram_bot_token" {
  description = "Telegram bot token from BotFather"
  type        = string
  sensitive   = true
}

variable "notion_api_key" {
  description = "Notion internal integration API key"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google OAuth2 client ID for Gmail, Calendar, and Drive"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth2 client secret"
  type        = string
  sensitive   = true
}

variable "google_refresh_token" {
  description = "Google OAuth2 refresh token for the dedicated Gmail account"
  type        = string
  sensitive   = true
}

variable "openclaw_gateway_token" {
  description = "Token for authenticating with the OpenClaw Gateway Control UI"
  type        = string
  sensitive   = true
}

variable "openclaw_port" {
  description = "Port for the OpenClaw Gateway"
  type        = string
  default     = "18789"
}

variable "project_name" {
  description = "Name of the Railway project"
  type        = string
  default     = "openclaw"
}

variable "github_repo" {
  description = "GitHub repository in org/repo format for Railway deployment"
  type        = string
}
