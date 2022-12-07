resource "google_project_organization_policy" "allowedPolicyMemberDomains" {
  project     = var.project_id
  constraint = "iam.allowedPolicyMemberDomains"
  list_policy {
    allow {
      all = true
    }
  }
}
resource "google_project_organization_policy" "requireShieldedVm" {
  project     = var.project_id
  constraint = "compute.requireShieldedVm"
  boolean_policy {
    enforced = false
  }
}
resource "google_project_organization_policy" "skipDefaultNetworkCreation" {
  project     = var.project_id
  constraint = "compute.skipDefaultNetworkCreation"
  boolean_policy {
    enforced = true
  }
}
resource "google_project_organization_policy" "vmExternalIpAccess" {
  project     = var.project_id
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    allow {
      all = true
    }
  }
}