variable "do_token" {
  type        = string
  description = "my Digital Ocean token"
  sensitive   = true
}

variable "ssh_key" {
  type        = string
  description = "SSH keys for servers"
  sensitive   = true
}

# domains & Network
variable "domain_name" {
  type        = string
  description = "domain name for server"
}


variable "space_access_id" {
  type        = string
  description = "Digital Ocean spaces access key"
  sensitive   = true
}

variable "space_secret_key" {
  type        = string
  description = "Digital Ocean spaces secret key"
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

variable reddit_schema_name {
  type        = string
  default     = "STAGING"
  description = "Snowflake schema name for Reddit news"
}


variable "airflow_user_password" {
  type        = string
  description = "Airflow Client Password"
  sensitive   = true
}


variable looker_user_password {
  type        = string
  description = "Looker client password"
  sensitive   = true
}
