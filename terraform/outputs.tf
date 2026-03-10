output "webgen_topic_name" {
  value = module.webgen_topic.topic_name
}

output "webgen_subscription_name" {
  value = module.webgen_topic.subscription_name
}

output "builder_templates_bucket_name" {
  value = module.builder_templates_bucket.name
}

output "project_snapshots_bucket_name" {
  value = module.project_snapshots_bucket.name
}

output "code_index_bucket_name" {
  value = module.code_index_bucket.name
}

output "generated_sites_artifact_repository" {
  value = google_artifact_registry_repository.generated_sites_web.repository_id
}
