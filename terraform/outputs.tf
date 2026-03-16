output "droplet_name" {
  description = "Created droplet name"
  value       = digitalocean_droplet.monitoring.name
}

output "droplet_ip" {
  description = "Public IPv4 address of the droplet"
  value       = digitalocean_droplet.monitoring.ipv4_address
}

output "ssh_key_name" {
  description = "DigitalOcean SSH key name"
  value       = digitalocean_ssh_key.vps_key.name
}

