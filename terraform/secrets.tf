resource "google_secret_manager_secret" "managed" {
  for_each = var.managed_secret_ids
  depends_on = [google_project_service.main]

  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "worker" {
  for_each = toset([
    for secret in values(var.worker_secret_env_vars) : secret.secret_id
  ])

  project   = var.project_id
  secret_id = google_secret_manager_secret.managed[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = module.worker_sa.member
}

resource "google_secret_manager_secret_iam_member" "builder" {
  for_each = toset([
    for secret in values(var.builder_secret_env_vars) : secret.secret_id
  ])

  project   = var.project_id
  secret_id = google_secret_manager_secret.managed[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = module.builder_sa.member
}

resource "google_secret_manager_secret_iam_member" "deployer" {
  for_each = toset([
    for secret in values(var.deployer_secret_env_vars) : secret.secret_id
  ])

  project   = var.project_id
  secret_id = google_secret_manager_secret.managed[each.value].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = module.deployer_sa.member
}
