data "google_project" "gcp_project" {
  project_id = var.gcp_project_id
}

data "google_compute_network" "vpc" {
  project = data.google_project.gcp_project.project_id
  name    = var.gcp_network_name
}


resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = "to-oci"
  project = data.google_project.gcp_project.project_id
  region  = var.gcp_vpn_region
  network = data.google_compute_network.vpc.name
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  count           = 2
  name            = "oci-${count.index + 1}"
  project         = data.google_project.gcp_project.project_id
  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id         = "0"
    ip_address = data.oci_core_ipsec_connection_tunnels.gcp[count.index].ip_sec_connection_tunnels[0].vpn_ip
  }

  interface {
    id         = "1"
    ip_address = data.oci_core_ipsec_connection_tunnels.gcp[count.index].ip_sec_connection_tunnels[1].vpn_ip
  }
}


resource "google_compute_router" "router" {

  name    = "vpn-to-oci"
  project = data.google_project.gcp_project.project_id
  region  = var.gcp_vpn_region
  network = data.google_compute_network.vpc.name
  bgp {
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range       = "199.36.153.8/30"
      description = "private.googleapis.com"
    }
    advertised_ip_ranges {
      range       = "199.36.153.4/30"
      description = "restricted.googleapis.com"
    }
    asn = var.gcp_asn
  }
}


resource "google_compute_vpn_tunnel" "tunnels_primary" {
  depends_on = [
    oci_core_ipsec_connection_tunnel_management.primary,
  ]
  count                           = 2
  project                         = data.google_project.gcp_project.project_id
  region                          = var.gcp_vpn_region
  name                            = "oci-primary-${count.index + 1}"
  router                          = google_compute_router.router.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway[count.index].id
  peer_external_gateway_interface = 0
  vpn_gateway_interface           = count.index
  ike_version                     = 2
  shared_secret                   = local.shared_secret
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.self_link
}


resource "google_compute_vpn_tunnel" "tunnels_secondary" {
  depends_on = [
    oci_core_ipsec_connection_tunnel_management.secondary,
  ]
  count                           = var.four_tunnels_redundancy ? 2 : 0
  project                         = data.google_project.gcp_project.project_id
  region                          = var.gcp_vpn_region
  name                            = "oci-secondary-${count.index + 1}"
  router                          = google_compute_router.router.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway[count.index].id
  peer_external_gateway_interface = 1
  vpn_gateway_interface           = count.index
  ike_version                     = 2
  shared_secret                   = local.shared_secret
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.self_link
}

resource "google_compute_router_interface" "router_interface_primary" {
  count      = 2
  project    = data.google_project.gcp_project.project_id
  region     = var.gcp_vpn_region
  name       = "oci-primary-${count.index + 1}"
  router     = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_primary[count.index].name
}

resource "google_compute_router_interface" "router_interface_secondary" {
  count      = var.four_tunnels_redundancy ? 2 : 0
  project    = data.google_project.gcp_project.project_id
  region     = var.gcp_vpn_region
  name       = "oci-secondary-${count.index + 1}"
  router     = google_compute_router.router.name
  vpn_tunnel = google_compute_vpn_tunnel.tunnels_secondary[count.index].name
}



resource "google_compute_router_peer" "bgp_peer_primary" {
  count           = 2
  project         = data.google_project.gcp_project.project_id
  region          = var.gcp_vpn_region
  name            = "oci-primary-${count.index + 1}"
  router          = google_compute_router.router.name
  ip_address      = "169.254.2${count.index + 1}.1" #oci_core_ipsec_connection_tunnel_management.primary[count.index].bgp_session_info[0].customer_interface_ip
  peer_ip_address = "169.254.2${count.index + 1}.2" #oci_core_ipsec_connection_tunnel_management.primary[count.index].bgp_session_info[0].oracle_interface_ip
  peer_asn        = oci_core_ipsec_connection_tunnel_management.primary[count.index].bgp_session_info[0].oracle_bgp_asn
  interface       = google_compute_router_interface.router_interface_primary[count.index].name
}


resource "google_compute_router_peer" "bgp_peer_secondary" {
  count           = var.four_tunnels_redundancy ? 2 : 0
  project         = data.google_project.gcp_project.project_id
  region          = var.gcp_vpn_region
  name            = "oci-secondary-${count.index + 1}"
  router          = google_compute_router.router.name
  ip_address      = "169.254.3${count.index + 1}.1" #oci_core_ipsec_connection_tunnel_management.primary[count.index].bgp_session_info[0].customer_interface_ip
  peer_ip_address = "169.254.3${count.index + 1}.2" #oci_core_ipsec_connection_tunnel_management.primary[count.index].bgp_session_info[0].oracle_interface_ip
  peer_asn        = oci_core_ipsec_connection_tunnel_management.secondary[count.index].bgp_session_info[0].oracle_bgp_asn
  interface       = google_compute_router_interface.router_interface_secondary[count.index].name
}