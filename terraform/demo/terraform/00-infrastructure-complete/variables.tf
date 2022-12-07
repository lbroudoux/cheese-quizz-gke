variable "project_id" {
  description = "The project where to deploy the demo"
  type        = string
}
variable "region" {
  description = "The region to use for deploying component"
  type        = string
  default     = "europe-west1"
}
variable "zone" {
  description = "The default zone to use for components"
  type        = string
  default     = "europe-west1-a"
}
variable "gke_zones" {
  description = "The zones to use for GKE cluster"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}
variable "gke_public_access_origin" {
  description = "The CIDR block that can access public endpoint of GKE"
  type        = string
  default     = "92.188.93.82/32"
}