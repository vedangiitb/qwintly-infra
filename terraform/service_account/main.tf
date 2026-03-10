resource "google_service_account" "sa" {
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "project_roles" {
  for_each = var.project_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
}
