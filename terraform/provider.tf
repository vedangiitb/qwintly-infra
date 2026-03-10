provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  alias   = "generated_sites"
  project = var.generated_sites_project_id
  region  = var.generated_sites_region
}
