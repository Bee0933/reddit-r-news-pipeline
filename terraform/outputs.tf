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

output "all_airflow_ips" {
  description = "A summary of all IPs for the Airflow server"
  value = {
    droplet_public_ip = digitalocean_droplet.airflow-server-0.ipv4_address
    reserved_ip       = digitalocean_reserved_ip.airflow-reserved-ip.ip_address
  }
}

output "spaces_bucket_details" {
  description = "Details of the DigitalOcean Spaces bucket"
  value = {
    name   = digitalocean_spaces_bucket.reddit-news-lake.name
    region = digitalocean_spaces_bucket.reddit-news-lake.region
    url    = "https://${digitalocean_spaces_bucket.reddit-news-lake.name}.${digitalocean_spaces_bucket.reddit-news-lake.region}.digitaloceanspaces.com"
  }
}
