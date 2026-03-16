locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "digitalocean_ssh_key" "vps_key" {
  name       = var.ssh_key_name
  public_key = local.ssh_public_key
}

resource "digitalocean_droplet" "monitoring" {
  name     = var.droplet_name
  region   = var.region
  size     = var.droplet_size
  image    = var.droplet_image
  ssh_keys = [digitalocean_ssh_key.vps_key.fingerprint]
  tags     = var.droplet_tags
}
