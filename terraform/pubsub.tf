module "webgen_dead_letter_topic" {
  source            = "./pubsub"
  topic_name        = local.webgen_dead_letter_topic_name
  subscription_name = local.webgen_dead_letter_subscription_name
  depends_on        = [google_project_service.main]

  topic_labels = merge(local.common_labels, {
    component = "webgen-dead-letter"
  })

  subscription_labels = merge(local.common_labels, {
    component = "webgen-dead-letter"
  })

  ack_deadline_seconds = 40
}

module "webdeploy_dead_letter_topic" {
  source            = "./pubsub"
  topic_name        = local.webdeploy_dead_letter_topic_name
  subscription_name = local.webdeploy_dead_letter_subscription_name
  depends_on        = [google_project_service.main]

  topic_labels = merge(local.common_labels, {
    component = "webdeploy-dead-letter"
  })

  subscription_labels = merge(local.common_labels, {
    component = "webdeploy-dead-letter"
  })

  ack_deadline_seconds = 40
}

module "webgen_topic" {
  source            = "./pubsub"
  topic_name        = local.webgen_topic_name
  subscription_name = local.webgen_subscription_name
  depends_on        = [google_project_service.main]

  topic_labels = merge(local.common_labels, {
    component = "webgen"
  })

  subscription_labels = merge(local.common_labels, {
    component = "webgen"
  })

  ack_deadline_seconds                     = 40
  retain_acked_messages                    = false
  enable_message_ordering                  = false
  enable_exactly_once_delivery             = false
  topic_message_retention_duration         = "3600s"
  subscription_message_retention_duration = "3600s"
  push_endpoint                            = "${trimsuffix(var.webgen_push_endpoint, "/")}/pubsub/generate"
  push_oidc_service_account_email          = module.pubsub_push_sa.email

  dead_letter_policy = {
    dead_letter_topic     = module.webgen_dead_letter_topic.topic_id
    max_delivery_attempts = 5
  }

  retry_policy = {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

module "webdeploy_topic" {
  source            = "./pubsub"
  topic_name        = local.webdeploy_topic_name
  subscription_name = local.webdeploy_subscription_name
  depends_on        = [google_project_service.main]

  topic_labels = merge(local.common_labels, {
    component = "webdeploy"
  })

  subscription_labels = merge(local.common_labels, {
    component = "webdeploy"
  })

  ack_deadline_seconds                     = 40
  retain_acked_messages                    = false
  enable_message_ordering                  = false
  enable_exactly_once_delivery             = false
  topic_message_retention_duration         = "3600s"
  subscription_message_retention_duration = "3600s"
  push_endpoint                            = "${trimsuffix(var.webgen_push_endpoint, "/")}/pubsub/deploy"
  push_oidc_service_account_email          = module.pubsub_push_sa.email

  dead_letter_policy = {
    dead_letter_topic     = module.webdeploy_dead_letter_topic.topic_id
    max_delivery_attempts = 5
  }

  retry_policy = {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}
