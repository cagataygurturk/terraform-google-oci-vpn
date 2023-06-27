<!-- BEGIN_TF_DOCS -->
# HA VPN between GCP and OCI

This repository contains a drop-in Terraform module that sets up a HA VPN between GCP and Oracle Cloud Infrastructure (OCI).

## Features

- Establishes a HA VPN on the GCP side with two or four tunnels. (Refer to the [documentation](https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-ha-vpn) for more information.)
- Sets up two Site-to-Site VPN connections on the OCI side with two connections each.
- Configures both sides to establish BGP sessions, allowing the two platforms to automatically learn routes from each other.
- Propagates proper routes from the GCP side to enable Private Google Access from OCI.

## Installation

On the OCI side: Create a compartment and a Distributed Routing Gateway (DRG).
On the GCP side: Set up a project and a VPC network.

## Example usage

````terraform
module "vpn" {

  source    = "registry.terraform.io/cagataygurturk/oci-vpn/google"
  version   = "1.0.0"
  providers = {
    google = google
    oci    = oci
  }

  gcp_network_name = var.gcp_network_name
  gcp_project_id   = var.gcp_project_id
  gcp_vpn_region   = var.gcp_vpn_region

  oci_compartment_id = var.oci_compartment_id
  oci_drg_id         = var.oci_drg_id
}
````

## Notes on high availability

For an HA VPN, Google Cloud creates two IP addresses that must be utilized by at least one tunnel each. When a Site-to-Site VPN is installed on the OCI side, two tunnels are created with diverse IPs. However, OCI does not support assigning these IPs to connect to two different Customer Premise Equipments (CPE). As a result, this module deploys two Site-to-Site VPNs, creating four tunnels in total. The module also provides the option to create four tunnels on the GCP side (two for each GCP VPN IP). By selecting this option, full high availability and higher bandwidth can be achieved. However, please note that each tunnel incurs an additional cost on the GCP side, and using four tunnels may be excessive. To address this, the module includes the four_tunnels_redundancy option, which allows for the use of only two tunnels. In this configuration, each GCP IP is terminated to one of the tunnels of the two Site-to-Site VPNs on the OCI side. With this setup, only one tunnel from each VPN on the OCI side will be utilized, and OCI might raise concerns about the lack of high availability. However, since two VPNs are established, high availability is still achieved.`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.30.0, < 5.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.30.0, < 5.0 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_project.gcp_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [oci_core_ipsec_connection_tunnels.gcp](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_ipsec_connection_tunnels) | data source |
| [oci_identity_compartment.compartment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_four_tunnels_redundancy"></a> [four\_tunnels\_redundancy](#input\_four\_tunnels\_redundancy) | Whether to deploy four tunnels or not. When set to `false`, only two tunnels are established. | `bool` | `false` | no |
| <a name="input_gcp_asn"></a> [gcp\_asn](#input\_gcp\_asn) | Specifies the ASN of GCP side of the BGP session | `number` | `65516` | no |
| <a name="input_gcp_network_name"></a> [gcp\_network\_name](#input\_gcp\_network\_name) | Specifies the name of the VPC the VPN will be located in | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | Specifies the project ID of Google project the VPN will be located in | `string` | n/a | yes |
| <a name="input_gcp_vpn_region"></a> [gcp\_vpn\_region](#input\_gcp\_vpn\_region) | Specifies the GCP region the VPN will be located in | `string` | n/a | yes |
| <a name="input_oci_compartment_id"></a> [oci\_compartment\_id](#input\_oci\_compartment\_id) | OCID of the compartment where the VPN will be created | `string` | n/a | yes |
| <a name="input_oci_drg_id"></a> [oci\_drg\_id](#input\_oci\_drg\_id) | OCID of the DRG (Dynamic Routing Gateway) where the VPN will be connected to | `string` | n/a | yes |
| <a name="input_shared_secret"></a> [shared\_secret](#input\_shared\_secret) | Shared secret for the VPN connection. When left empty, a random secret is created and shared between GCP and OCI. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_shared_secret"></a> [shared\_secret](#output\_shared\_secret) | Shared Secret that was used to establish the VPN connection |

## License

[Apache License 2.0](LICENSE)
<!-- END_TF_DOCS -->
