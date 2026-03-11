output "email" {
  value = google_service_account.sa.email
}

output "member" {
  value = "serviceAccount:${google_service_account.sa.email}"
}

output "name" {
  value = google_service_account.sa.name
}
