module "logs_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = "qwintly-logs-${local.environment_suffix}"
  location = upper(var.region)
  kms_key_name = google_kms_crypto_key.key.id
  depends_on = [google_project_service.main, google_kms_crypto_key_iam_member.storage_kms_key_user]
  labels = merge(local.common_labels, {
    component = "logs"
  })
}

module "builder_templates_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.builder_templates_bucket_name
  location = upper(var.region)
  logging_bucket = module.logs_bucket.name
  kms_key_name = google_kms_crypto_key.key.id
  depends_on = [google_project_service.main, google_kms_crypto_key_iam_member.storage_kms_key_user]
  labels = merge(local.common_labels, {
    component = "builder-templates"
  })
}

module "project_snapshots_bucket" {
  source   = "./gcs_bucket"
  project_id = var.generated_sites_project_id
  name     = local.project_snapshots_bucket_name
  location = upper(var.region)
  logging_bucket = module.logs_bucket.name
  kms_key_name = google_kms_crypto_key.key.id
  providers = {
    google = google.generated_sites
  }
  depends_on = [google_project_service.generated_sites, google_kms_crypto_key_iam_member.storage_kms_key_user]
  labels = merge(local.common_labels, {
    component = "project-snapshots"
  })
}

module "code_index_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.code_index_bucket_name
  location = upper(var.region)
  logging_bucket = module.logs_bucket.name
  kms_key_name = google_kms_crypto_key.key.id
  depends_on = [google_project_service.main, google_kms_crypto_key_iam_member.storage_kms_key_user]
  labels = merge(local.common_labels, {
    component = "code-index"
  })
}

module "agent_logs_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.agent_logs_bucket_name
  location = upper(var.region)
  logging_bucket = module.logs_bucket.name
  kms_key_name = google_kms_crypto_key.key.id
  depends_on = [google_project_service.main, google_kms_crypto_key_iam_member.storage_kms_key_user]
  labels = merge(local.common_labels, {
    component = "agent-logs"
  })
}
