data "oci_identity_compartment" "compartment" {
  id = var.oci_compartment_id
}

resource "oci_core_cpe" "gcp" {
  count          = 2
  compartment_id = data.oci_identity_compartment.compartment.id
  ip_address     = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[count.index].ip_address
  display_name   = "gcp-${count.index + 1}"
}

resource "oci_core_ipsec" "gcp" {
  count          = 2
  compartment_id = data.oci_identity_compartment.compartment.id
  cpe_id         = oci_core_cpe.gcp[count.index].id
  drg_id         = var.oci_drg_id
  display_name   = "to-gcp-${count.index + 1}"
  static_routes = [
    "1.1.1.1/32" #https://github.com/oracle/terraform-provider-oci/issues/1509#issuecomment-1126299971
  ]

}

data "oci_core_ipsec_connection_tunnels" "gcp" {
  count    = 2
  ipsec_id = oci_core_ipsec.gcp[count.index].id
}

resource "oci_core_ipsec_connection_tunnel_management" "primary" {
  count = 2
  #Required
  ipsec_id  = oci_core_ipsec.gcp[count.index].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.gcp[count.index].ip_sec_connection_tunnels[0].id
  routing   = "BGP"
  #Optional
  display_name = "to-gcp-${count.index + 1}-primary"
  bgp_session_info {
    #Optional
    customer_bgp_asn      = var.gcp_asn
    customer_interface_ip = "169.254.2${count.index + 1}.1/30"
    oracle_interface_ip   = "169.254.2${count.index + 1}.2/30"
  }

  shared_secret = local.shared_secret
  ike_version   = "V2"
}

resource "oci_core_ipsec_connection_tunnel_management" "secondary" {
  count = 2
  #Required
  ipsec_id  = oci_core_ipsec.gcp[count.index].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.gcp[count.index].ip_sec_connection_tunnels[1].id
  routing   = "BGP"
  #Optional
  display_name = "to-gcp-${count.index + 1}-primary"
  bgp_session_info {
    #Optional
    customer_bgp_asn      = var.gcp_asn
    customer_interface_ip = "169.254.3${count.index + 1}.1/30"
    oracle_interface_ip   = "169.254.3${count.index + 1}.2/30"
  }
  shared_secret = local.shared_secret
  ike_version   = "V2"
}