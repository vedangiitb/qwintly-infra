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
    "roles/run.jobsExecutorWithOverrides",
    "roles/run.viewer",
  ]
}

module "pubsub_push_sa" {
  source       = "./service_account"
  project_id   = var.project_id
  account_id   = "qwintly-pubsub-push-sa"
  display_name = "Qwintly Pub/Sub Push Service Account"
  depends_on   = [google_project_service.main]
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

module "gateway_service_sa" {
  source     = "./service_account"
  project_id = var.project_id
  account_id   = "qwintly-gateway-service-sa"
  display_name = "Gateway Service Service Account"
  depends_on = [google_project_service.main]
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

resource "google_kms_crypto_key_iam_member" "builder_sa_user_api_keys_encrypter_decrypter" {
  crypto_key_id = "projects/${var.project_id}/locations/global/keyRings/qwintly-keyring/cryptoKeys/user-api-keys"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = module.builder_sa.member
  depends_on    = [google_project_service.main]
}

resource "google_kms_crypto_key_iam_member" "deployer_sa_user_api_keys_encrypter_decrypter" {
  crypto_key_id = "projects/${var.project_id}/locations/global/keyRings/qwintly-keyring/cryptoKeys/user-api-keys"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = module.deployer_sa.member
  depends_on    = [google_project_service.main]
}

resource "google_kms_crypto_key_iam_member" "qwintly_main_sa_user_api_keys_encrypter_decrypter" {
  crypto_key_id = "projects/${var.project_id}/locations/global/keyRings/qwintly-keyring/cryptoKeys/user-api-keys"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = module.qwintly_main_sa.member
  depends_on    = [google_project_service.main]
}
