output "airflow_droplet_details" {
  description = "Details of the Airflow server droplet"
  value = {
    name       = digitalocean_droplet.airflow-server-0.name
    public_ip  = digitalocean_droplet.airflow-server-0.ipv4_address
    region     = digitalocean_droplet.airflow-server-0.region
    tags       = digitalocean_droplet.airflow-server-0.tags
    droplet_id = digitalocean_droplet.airflow-server-0.id
  }
}

output "airflow_reserved_ip" {
  description = "The reserved IP associated with the Airflow droplet"
  value       = digitalocean_reserved_ip.airflow-reserved-ip.ip_address
}

output "spaces_bucket_details" {
  description = "Details of the DigitalOcean Spaces bucket"
  value = {
    name   = digitalocean_spaces_bucket.reddit-news-lake.name
    region = digitalocean_spaces_bucket.reddit-news-lake.region
    url    = "https://${digitalocean_spaces_bucket.reddit-news-lake.name}.${digitalocean_spaces_bucket.reddit-news-lake.region}.digitaloceanspaces.com"
  }
}

output "airflow_snowflake_svc_public_key" {
  value = tls_private_key.airflow_svc_key.public_key_pem
}

output "airflow_snowflake_svc_private_key" {
  value     = tls_private_key.airflow_svc_key.private_key_pem
  sensitive = true
}
