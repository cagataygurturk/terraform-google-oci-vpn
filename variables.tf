# Common variables

variable "shared_secret" {
  type        = string
  default     = null
  description = "Shared secret for the VPN connection. When left empty, a random secret is created and shared between GCP and OCI."
}

# GCP variables
variable "gcp_project_id" {
  type        = string
  description = "Specifies the project ID of Google project the VPN will be located in"
}

variable "gcp_network_name" {
  type        = string
  description = "Specifies the name of the VPC the VPN will be located in"
}

variable "gcp_vpn_region" {
  type        = string
  description = "Specifies the GCP region the VPN will be located in"
}

variable "gcp_asn" {
  type        = number
  description = "Specifies the ASN of GCP side of the BGP session"
  default     = 65516
}

# OCI
variable "oci_compartment_id" {
  type        = string
  description = "OCID of the compartment where the VPN will be created"
}

variable "oci_drg_id" {
  type        = string
  description = "OCID of the DRG (Dynamic Routing Gateway) where the VPN will be connected to"
}

variable "four_tunnels_redundancy" {
  type        = bool
  default     = false
  description = "Whether to deploy four tunnels or not. When set to `false`, only two tunnels are established."
}