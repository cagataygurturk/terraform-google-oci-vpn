terraform {
  required_providers {
    oci = {
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.30.0, < 5.0"
    }
  }
}

resource "random_password" "shared_secret" {
  count   = var.shared_secret == null ? 1 : 0
  length  = 16
  lower   = true
  special = false
}

locals {
  shared_secret = var.shared_secret == null ? random_password.shared_secret[0].result : var.shared_secret
}

output "shared_secret" {
  sensitive   = true
  value       = local.shared_secret
  description = "Shared Secret that was used to establish the VPN connection"
}