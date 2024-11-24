# Create a new SSH key
resource "digitalocean_ssh_key" "default" {
  name       = "Airflow servers SSH key"
  public_key = var.ssh_key
}

# Airlow Server droplet in the Frankfut region
resource "digitalocean_droplet" "airflow-server-0" {
  image  = "ubuntu-24-04-x64"
  name   = "airflow-server-0"
  region = "fra1"
  size   = "s-4vcpu-8gb"

  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  tags     = ["Airflow:DE"]
}

# Airflow reserved IP
resource "digitalocean_reserved_ip" "airflow-reserved-ip" {
  droplet_id = digitalocean_droplet.airflow-server-0.id
  region     = digitalocean_droplet.airflow-server-0.region
}

# DigitalOcean Space bucket (S3) for reddit-r-news
resource "digitalocean_spaces_bucket" "reddit-news-lake" {
  name   = "reddit-news-lake"
  region = "fra1"
}

# bucket cors configs
resource "digitalocean_spaces_bucket_cors_configuration" "reddit-news-lake-cors-config" {
  bucket = digitalocean_spaces_bucket.reddit-news-lake.id
  region = "fra1"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://s3-website-test.hashicorp.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
