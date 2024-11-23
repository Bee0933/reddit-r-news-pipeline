terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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


