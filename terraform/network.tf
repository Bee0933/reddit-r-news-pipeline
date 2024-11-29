# Airflow server firewall configs 
resource "digitalocean_firewall" "airflow-server-fw" {
  name = "airflow-server-firewall"

  droplet_ids = [digitalocean_droplet.airflow-server-0.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }


  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # loki
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3100"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # loki
  outbound_rule {
    protocol              = "tcp"
    port_range            = "3100"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}


# Monitor server firewall configs 
resource "digitalocean_firewall" "monitor-server-fw" {
  name = "monitor-server-firewall"

  droplet_ids = [digitalocean_droplet.monitor-server-0.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }


  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # # node exporter
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "9100"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # # prometheus
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "9090"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # loki
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3100"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # # grafana
  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "3000"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # # node exporter
  # outbound_rule {
  #   protocol              = "tcp"
  #   port_range            = "9100"
  #   destination_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # # prometheus
  # outbound_rule {
  #   protocol              = "tcp"
  #   port_range            = "9090"
  #   destination_addresses = ["0.0.0.0/0", "::/0"]
  # }

  # loki
  outbound_rule {
    protocol              = "tcp"
    port_range            = "3100"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  # # grafana
  # outbound_rule {
  #   protocol              = "tcp"
  #   port_range            = "3000"
  #   destination_addresses = ["0.0.0.0/0", "::/0"]
  # }
}