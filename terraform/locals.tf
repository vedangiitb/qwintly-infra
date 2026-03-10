locals {
  environment_suffix = lower(replace(var.environment, "_", "-"))

  common_labels = {
    app         = "qwintly"
    environment = local.environment_suffix
  }

  webgen_topic_name                     = "${var.webgen_topic_name}-${local.environment_suffix}"
  webgen_subscription_name              = "${var.webgen_subscription_name}-${local.environment_suffix}"
  webgen_dead_letter_topic_name         = "${var.webgen_dead_letter_topic_name}-${local.environment_suffix}"
  webgen_dead_letter_subscription_name  = "${var.webgen_dead_letter_subscription_name}-${local.environment_suffix}"
  builder_templates_bucket_name         = "${var.builder_templates_bucket_name}-${local.environment_suffix}"
  project_snapshots_bucket_name         = "${var.project_snapshots_bucket_name}-${local.environment_suffix}"
  code_index_bucket_name                = "${var.code_index_bucket_name}-${local.environment_suffix}"
  generated_sites_artifact_repo_name    = "generated-sites-web-${local.environment_suffix}"
  generated_sites_runtime_service_name  = "generated-site-runtime-${local.environment_suffix}"
  generated_sites_cloudbuild_sa_id      = "gensites-cb-${local.environment_suffix}"
  generated_sites_runtime_sa_id         = "generated-sites-runtime-${local.environment_suffix}"
}
