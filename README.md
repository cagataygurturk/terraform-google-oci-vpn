<!-- BEGIN_TF_DOCS -->
# HA VPN between GPC and OCI

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
| <a name="output_share"></a> [share](#output\_share) | n/a |
| <a name="output_shared_secret"></a> [shared\_secret](#output\_shared\_secret) | n/a |
<!-- END_TF_DOCS -->