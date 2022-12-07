module "infrastructure" {
  source                   = "./00-infrastructure-complete"
  project_id               = var.project_id
  region                   = var.region
  zone                     = var.zone
  gke_zones                = var.gke_zones
  gke_public_access_origin = var.gke_public_access_origin
}

module "servicemesh" {
  count      = var.enabled_servicemesh ? 1 : 0
  source     = "./01-servicemesh-complete"
  //project_id = var.project_id
  //region     = var.region
  //zone       = var.zone

  depends_on = [
    module.infrastructure
  ]
}

module "devexp" {
  count      = var.enabled_devexp ? 1 : 0
  source     = "./02-devexp-complete"
  //project_id = var.project_id
  //region     = var.region
  //zone       = var.zone

  depends_on = [
    module.servicemesh
  ]
}

module "integration" {
  count      = var.enabled_integration ? 1 : 0
  source     = "./03-integration-complete"
  //project_id = var.project_id
  //region     = var.region
  //zone       = var.zone

  depends_on = [
    module.devexp
  ]
}
