resource "google_artifact_registry_repository" "generated_sites_web" {
  provider = google.generated_sites
  depends_on = [google_project_service.generated_sites]

  project       = var.generated_sites_project_id
  location      = var.generated_sites_region
  repository_id = local.generated_sites_artifact_repo_name
  description   = "Container images for generated sites"
  format        = "DOCKER"
}
