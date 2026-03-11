module "builder_templates_bucket" {
  source   = "./gcs_bucket"
  name     = local.builder_templates_bucket_name
  location = upper(var.region)
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "builder-templates"
  })
}

module "project_snapshots_bucket" {
  source   = "./gcs_bucket"
  name     = local.project_snapshots_bucket_name
  location = upper(var.region)
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "project-snapshots"
  })
}

module "code_index_bucket" {
  source   = "./gcs_bucket"
  name     = local.code_index_bucket_name
  location = upper(var.region)
  depends_on = [google_project_service.main]
  labels = merge(local.common_labels, {
    component = "code-index"
  })
}
