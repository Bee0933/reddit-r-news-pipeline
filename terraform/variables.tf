variable "do_token" {
  type        = string
  description = "my do token"
  sensitive   = true
}

variable "ssh_key" {
  type        = string
  description = "SSH keys for SFTP platform servers"
  sensitive   = true
}

variable "space_access_id" {
  type        = string
  description = "DO spaces access key"
  sensitive   = true
}

variable "space_secret_key" {
  type        = string
  description = "DO spaces secret key"
  sensitive   = true

}

variable "snowflake_account" {
  type        = string
  description = "snowflake account"
  sensitive   = true
}

variable "snowflake_org_name" {
  type        = string
  description = "snowflake organization name"
  sensitive   = true
}

variable "snowflake_user" {
  type        = string
  description = "snowflake user for terraform"
}

variable "snowflake_password" {
  type        = string
  description = "snowflake password"
  sensitive   = true
}

variable "snowflake_role" {
  type        = string
  default     = "ACCOUNTADMIN"
  description = "Snowflake Warehouse role"
}


variable "snowflake_db_name" {
  type        = string
  default     = "REDDIT_DATABASE"
  description = "Snowflake Database name for Reddit news"
}

variable "airflow_user_password" {
  type        = string
  description = "description"
  sensitive   = true
}
