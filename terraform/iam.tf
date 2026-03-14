resource "google_pubsub_subscription_iam_member" "worker_subscriber" {
  project      = var.project_id
  subscription = module.webgen_topic.subscription_name
  role         = "roles/pubsub.subscriber"
  member       = module.worker_sa.member
}

resource "google_pubsub_topic_iam_member" "webgen_publisher" {
  project = var.project_id
  topic   = module.webgen_topic.topic_name
  role    = "roles/pubsub.publisher"
  member  = module.qwintly_main_sa.member
}

resource "google_storage_bucket_iam_member" "builder_templates_viewer" {
  bucket = module.builder_templates_bucket.name
  role   = "roles/storage.objectViewer"
  member = module.builder_sa.member
}

resource "google_storage_bucket_iam_member" "builder_snapshots_admin" {
  bucket = module.project_snapshots_bucket.name
  role   = "roles/storage.objectAdmin"
  member = module.builder_sa.member
}

resource "google_storage_bucket_iam_member" "builder_code_index_admin" {
  bucket = module.code_index_bucket.name
  role   = "roles/storage.objectAdmin"
  member = module.builder_sa.member
}

resource "google_storage_bucket_iam_member" "deployer_snapshots_admin" {
  bucket = module.project_snapshots_bucket.name
  role   = "roles/storage.objectAdmin"
  member = module.deployer_sa.member
}

resource "google_storage_bucket_iam_member" "deployer_code_index_admin" {
  bucket = module.code_index_bucket.name
  role   = "roles/storage.objectAdmin"
  member = module.deployer_sa.member
}

resource "google_storage_bucket_iam_member" "cloudbuild_snapshots_viewer" {
  bucket = module.project_snapshots_bucket.name
  role = "roles/storage.objectViewer"
  member = module.generated_sites_cloudbuild_sa.member
}

resource "google_project_iam_member" "deployer_generated_sites_cloudbuild_editor" {
  provider = google.generated_sites

  project = var.generated_sites_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = module.deployer_sa.member
}

resource "google_project_iam_member" "deployer_generated_sites_logging_viewer" {
  provider = google.generated_sites

  project = var.generated_sites_project_id
  role    = "roles/logging.viewer"
  member  = module.deployer_sa.member
}

resource "google_project_iam_member" "deployer_generated_sites_run_admin" {
  provider = google.generated_sites

  project = var.generated_sites_project_id
  role    = "roles/run.admin"
  member  = module.deployer_sa.member
}

resource "google_service_account_iam_member" "deployer_use_generated_sites_cloudbuild_sa" {
  provider = google.generated_sites

  service_account_id = module.generated_sites_cloudbuild_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = module.deployer_sa.member
}

resource "google_service_account_iam_member" "cloudbuild_use_generated_sites_runtime_sa" {
  provider = google.generated_sites

  service_account_id = module.generated_sites_runtime_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = module.generated_sites_cloudbuild_sa.member
}