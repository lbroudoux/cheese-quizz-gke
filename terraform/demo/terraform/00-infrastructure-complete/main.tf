provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_project" "project" {
}

// Enable required services
resource "google_project_service" "compute_service" {
  project = var.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "network_service" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}
resource "google_project_service" "container_service" {
  project = var.project_id
  service = "container.googleapis.com"
}
resource "google_project_service" "artifactregistry_service" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}
resource "google_project_service" "anthos_service" {
  project = var.project_id
  service = "anthos.googleapis.com"
}
resource "google_project_service" "mesh_service" {
  project = var.project_id
  service = "mesh.googleapis.com"
}
resource "google_project_service" "meshconfig_service" {
  project = var.project_id
  service = "meshconfig.googleapis.com"
}
resource "google_project_service" "cloudbuild_service" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

// Create a new default VPC network if not already existing into your project.
// Check constraints/compute.skipDefaultNetworkCreation policy
resource "google_compute_network" "vpc_network" {
  name                    = "default"
  auto_create_subnetworks = "false"
}
resource "google_compute_subnetwork" "gke-network-with-ip-ranges" {
  name          = "default"
  ip_cidr_range = "10.132.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc_network.name

  secondary_ip_range {
    range_name    = "${var.region}-gke-01-pods"
    ip_cidr_range = "10.88.0.0/14"
  }
  secondary_ip_range {
    range_name    = "${var.region}-gke-01-services"
    ip_cidr_range = "10.92.0.0/20"
  }
}
resource "google_compute_router" "router" {
  name    = "cloud-router"
  region  = var.region
  network = google_compute_network.vpc_network.name
  bgp {
    asn = 64514
  }
}
resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

// Create a private GKE cluster in default VPC using the subnetwork ip ranges we declared previsouly.
resource "google_container_cluster" "cluster-1" {
  provider = google-beta
  name     = "cluster-1"

  location = var.region

  resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  network         = google_compute_network.vpc_network.name
  subnetwork      = google_compute_subnetwork.gke-network-with-ip-ranges.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.region}-gke-01-pods"
    services_secondary_range_name = "${var.region}-gke-01-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
    master_global_access_config {
      enabled = true
    }
  }

  network_policy {
    enabled = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.gke_public_access_origin
      display_name = "Public access origin"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  node_pool {
    initial_node_count = 1
    name               = "default-pool"
    node_locations     = var.gke_zones
    autoscaling {
      min_node_count = 1
      max_node_count = 4
    }
    node_config {
      preemptible  = false
      machine_type = "e2-medium"
      disk_size_gb = "60"
      disk_type    = "pd-standard"
      shielded_instance_config {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
  }
  enable_shielded_nodes = true
  /*
  addons_config {
    istio_config {
      disabled = false
    }
  }
  */
}

// Enable Anthos Service Mesh feature in fleet
resource "google_gke_hub_feature" "service_mesh_feature" {
  name     = "servicemesh"
  location = "global"
  provider = google-beta
}
// Add the cluster into a fleet membership
resource "google_gke_hub_membership" "cluster-1_membership" {
  membership_id = "cluster-1"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster-1.id}"
    }
  }
}
// Declare cluster-1 mesh membership config as automatic ControlPlane
resource "google_gke_hub_feature_membership" "cluster-1_feature_member" {
  location   = "global"
  feature    = google_gke_hub_feature.service_mesh_feature.name
  membership = google_gke_hub_membership.cluster-1_membership.membership_id
  mesh {
    control_plane = "AUTOMATIC"
  }
  provider = google-beta
}
