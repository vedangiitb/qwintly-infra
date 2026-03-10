variable "topic_name" {
  type = string
}

variable "subscription_name" {
  type    = string
  default = null
}

variable "topic_labels" {
  type    = map(string)
  default = {}
}

variable "subscription_labels" {
  type    = map(string)
  default = {}
}

variable "kms_key_name" {
  type    = string
  default = null
}

variable "topic_message_retention_duration" {
  type    = string
  default = null
}

variable "allowed_persistence_regions" {
  type    = list(string)
  default = []
}

variable "schema_settings" {
  type = object({
    schema   = string
    encoding = string
  })
  default = null
}

variable "ack_deadline_seconds" {
  type    = number
  default = 10
}

variable "subscription_message_retention_duration" {
  type    = string
  default = null
}

variable "retain_acked_messages" {
  type    = bool
  default = false
}

variable "enable_message_ordering" {
  type    = bool
  default = false
}

variable "enable_exactly_once_delivery" {
  type    = bool
  default = false
}

variable "subscription_filter" {
  type    = string
  default = null
}

variable "subscription_expiration_ttl" {
  type    = string
  default = null
}

variable "dead_letter_policy" {
  type = object({
    dead_letter_topic     = string
    max_delivery_attempts = number
  })
  default = null
}

variable "retry_policy" {
  type = object({
    minimum_backoff = string
    maximum_backoff = string
  })
  default = null
}
