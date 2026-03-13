terraform {
  required_providers {
    hetzner = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "k3s_lab" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.server_image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.k3s_lab.id]

  user_data = file("${path.module}/user_data.sh")

  labels = {
    environment = "lab"
    project     = "k3s-gitops"
  }
}

resource "hcloud_ssh_key" "k3s_lab" {
  name       = "k3s-lab-key"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "k3s_lab" {
  name = "k3s-lab-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "30000-32767"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall_attachment" "k3s_lab" {
  firewall_id = hcloud_firewall.k3s_lab.id
  server_ids  = [hcloud_server.k3s_lab.id]
}