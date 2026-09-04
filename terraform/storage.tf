module "builder_templates_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.builder_templates_bucket_name
  location = upper(var.region)
  kms_key_name = var.kms_key_name
  log_bucket   = var.log_bucket
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "builder-templates"
  })
}

module "project_snapshots_bucket" {
  source   = "./gcs_bucket"
  project_id = var.generated_sites_project_id
  name     = local.project_snapshots_bucket_name
  location = upper(var.region)
  kms_key_name = var.kms_key_name
  log_bucket   = var.log_bucket
  providers = {
    google = google.generated_sites
  }
  depends_on = [google_project_service.generated_sites]
  labels = merge(local.common_labels, {
    component = "project-snapshots"
  })
}

module "code_index_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.code_index_bucket_name
  location = upper(var.region)
  kms_key_name = var.kms_key_name
  log_bucket   = var.log_bucket
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "code-index"
  })
}

module "agent_logs_bucket" {
  source   = "./gcs_bucket"
  project_id = var.project_id
  name     = local.agent_logs_bucket_name
  location = upper(var.region)
  kms_key_name = var.kms_key_name
  log_bucket   = var.log_bucket
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "agent-logs"
  })
}
