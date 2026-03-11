resource "google_storage_bucket" "bucket" {
  name                        = var.name
  location                    = var.location
  labels                      = var.labels
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = try(lifecycle_rule.value.action.storage_class, null)
      }

      condition {
        age                   = try(lifecycle_rule.value.condition.age, null)
        with_state            = try(lifecycle_rule.value.condition.with_state, null)
        matches_storage_class = try(lifecycle_rule.value.condition.matches_storage_class, null)
      }
    }
  }
}
