terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.61"
    }
  }
  cloud {

    organization = "nyah-core"

    workspaces {
      name = "airflow-de"
    }
  }
}

# DigitalOcean Provider
provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.space_access_id
  spaces_secret_key = var.space_secret_key
}

# Snowflake Provider
provider "snowflake" {
  user              = var.snowflake_user
  password          = var.snowflake_password
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org_name
  role              = var.snowflake_role
}