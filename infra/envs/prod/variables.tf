variable "db_password" {
  description = "Master password for the RDS PostgreSQL database"
  type        = string
  sensitive   = true
}


variable "github_org" {
  description = "GitHub username or organization that owns zen-tomato-frontend and zen-tomato-backend (e.g. john-smith)"
  type        = string
  default     = "ravibhadarge"
}
