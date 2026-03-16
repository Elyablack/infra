variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "fra1"
}

variable "droplet_name" {
  description = "Droplet name"
  type        = string
  default     = "monitoring-vps"
}

variable "droplet_size" {
  description = "Droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "droplet_image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key used for VPS access"
  type        = string
  default     = "~/.ssh/vps_ed25519.pub"
}

variable "ssh_key_name" {
  description = "Name of SSH key in DigitalOcean"
  type        = string
  default     = "elvira-vps-key"
}

variable "droplet_tags" {
  description = "Tags applied to the droplet"
  type        = list(string)
  default     = ["monitoring", "terraform"]
}
