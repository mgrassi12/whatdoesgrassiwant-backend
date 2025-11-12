variable "location" {
  description = "Azure region for backend resources"
  type        = string
  default     = "australiaeast"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "whatdoesgrassiwant"
}

variable "sql_admin_login" {
  description = "Admin login name for SQL server"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Admin password for SQL server"
  type        = string
  sensitive   = true
}