resource "google_kms_key_ring" "keyring" {
  name     = "qwintly-keyring-${local.environment_suffix}"
  location = var.region
}

resource "google_kms_crypto_key" "key" {
  name     = "qwintly-key-${local.environment_suffix}"
  key_ring = google_kms_key_ring.keyring.id
}

resource "google_kms_crypto_key_iam_member" "storage_kms_key_user" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

data "google_project" "project" {
}
