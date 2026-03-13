variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "generated_sites_project_id" {
  type = string
}

variable "generated_sites_region" {
  type    = string
  default = "asia-south1"
}

variable "webgen_topic_name" {
  type    = string
  default = "webgen-topic"
}

variable "webgen_subscription_name" {
  type    = string
  default = "webgen-topic-sub"
}

variable "webgen_dead_letter_topic_name" {
  type    = string
  default = "webgen-topic-dlq"
}

variable "webgen_dead_letter_subscription_name" {
  type    = string
  default = "webgen-topic-dlq-sub"
}

variable "builder_templates_bucket_name" {
  type    = string
  default = "builder-templates"
}

variable "project_snapshots_bucket_name" {
  type    = string
  default = "gen-project-snapshots"
}

variable "code_index_bucket_name" {
  type    = string
  default = "code-index"
}

variable "managed_secret_ids" {
  type = set(string)
  default = [
    "supabase-url",
    "supabase-secret-key",
    "upstash-redis-rest-token-gen-events",
    "upstash-redis-rest-url-gen-events",
    "gemini-api-key",
    "pubsub-subscription"
  ]
}

variable "worker_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    NEXT_PUBLIC_SUPABASE_URL = {
      secret_id = "supabase-url"
    }
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
    UPSTASH_REDIS_REST_TOKEN_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-token-gen-events"
    }
    UPSTASH_REDIS_REST_URL_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-url-gen-events"
    }
    PUBSUB_SUBSCRIPTION = {
      secret_id = "pubsub-subscription"
    }
  }
}

variable "builder_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    GEMINI_API_KEY = {
      secret_id = "gemini-api-key"
    }
    NEXT_PUBLIC_SUPABASE_URL = {
      secret_id = "supabase-url"
    }
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
  }
}

variable "deployer_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    GEMINI_API_KEY = {
      secret_id = "gemini-api-key"
    }
    NEXT_PUBLIC_SUPABASE_URL = {
      secret_id = "supabase-url"
    }
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
  }
}
