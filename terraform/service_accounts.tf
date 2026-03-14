module "worker_sa" {
  source       = "./service_account"
  project_id   = var.project_id
  account_id   = "qwintly-wg-worker-sa"
  display_name = "Qwintly WG Worker Service Account"
  depends_on   = [google_project_service.main]
  project_roles = [
    "roles/logging.logWriter",
    "roles/logging.viewer",
    "roles/monitoring.metricWriter",
    "roles/run.jobsExecutor",
  ]
}

module "builder_sa" {
  source       = "./service_account"
  project_id   = var.project_id
  account_id   = "qwintly-builder-sa"
  display_name = "Qwintly Builder Service Account"
  depends_on   = [google_project_service.main]
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

module "deployer_sa" {
  source       = "./service_account"
  project_id   = var.project_id
  account_id   = "qwintly-deployer-sa"
  display_name = "Qwintly Deployer Service Account"
  depends_on   = [google_project_service.main]
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

module "qwintly_main_sa" {
  source       = "./service_account"
  project_id   = var.project_id
  account_id   = "qwintly-main-sa"
  display_name = "Qwintly Main Project Service Account"
  depends_on   = [google_project_service.main]
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

module "generated_sites_cloudbuild_sa" {
  source     = "./service_account"
  project_id = var.generated_sites_project_id
  depends_on = [google_project_service.generated_sites]
  providers = {
    google = google.generated_sites
  }
  account_id   = local.generated_sites_cloudbuild_sa_id
  display_name = "Generated Sites Cloud Build Service Account"
  project_roles = [
    "roles/artifactregistry.writer",
    "roles/logging.logWriter",
    "roles/run.admin",
    "roles/storage.admin",
  ]
}

module "generated_sites_runtime_sa" {
  source     = "./service_account"
  project_id = var.generated_sites_project_id
  depends_on = [google_project_service.generated_sites]
  providers = {
    google = google.generated_sites
  }
  account_id   = local.generated_sites_runtime_sa_id
  display_name = "Generated Sites Runtime Service Account"
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}
