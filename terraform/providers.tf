terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }
  }
  cloud {

    organization = "nyah-core"

    workspaces {
      name = "airflow-de"
    }
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.space_access_id
  spaces_secret_key = var.space_secret_key
}

provider "snowflake" {
  role              = "SYSADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key
  account_name      = var.snowflake_account
  organization_name = var.snowflake_org_name
  user              = var.snowflake_user
}