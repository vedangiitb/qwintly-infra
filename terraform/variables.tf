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

variable "webgen_push_endpoint" {
  type = string
}

variable "webgen_dead_letter_topic_name" {
  type    = string
  default = "webgen-topic-dlq"
}

variable "webgen_dead_letter_subscription_name" {
  type    = string
  default = "webgen-topic-dlq-sub"
}

variable "webdeploy_topic_name" {
  type    = string
  default = "webdeploy-topic"
}

variable "webdeploy_subscription_name" {
  type    = string
  default = "webdeploy-topic-sub"
}

variable "webdeploy_dead_letter_topic_name" {
  type    = string
  default = "webdeploy-topic-dlq"
}

variable "webdeploy_dead_letter_subscription_name" {
  type    = string
  default = "webdeploy-topic-dlq-sub"
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
    "supabase-secret-key",
    "supabase-secret-key-dev",
    "upstash-redis-rest-token-gen-events",
    "gemini-api-key",
    "publish-secret",
    "unsplash-api-key"
  ]
}

variable "worker_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
    UPSTASH_REDIS_REST_TOKEN_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-token-gen-events"
    }
    PUBLISH_SECRET = {
      secret_id = "publish-secret"
    }
  }
}

variable "builder_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
    UPSTASH_REDIS_REST_TOKEN_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-token-gen-events"
    }
    PUBLISH_SECRET = {
      secret_id = "publish-secret"
    }
    UNSPLASH_API_KEY = {
      secret_id = "unsplash-api-key"
    }
  }
}

variable "deployer_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    SUPABASE_SECRET_KEY = {
      secret_id = "supabase-secret-key"
    }
    UPSTASH_REDIS_REST_TOKEN_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-token-gen-events"
    }
    PUBLISH_SECRET = {
      secret_id = "publish-secret"
    }
    UNSPLASH_API_KEY = {
      secret_id = "unsplash-api-key"
    }
  }
}

variable "qwintly_main_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    GEMINI_API_KEY = {
      secret_id = "gemini-api-key"
    }
    UPSTASH_REDIS_REST_TOKEN_GEN_EVENTS = {
      secret_id = "upstash-redis-rest-token-gen-events"
    }
    WORKER_PUBLISH_SECRET = {
      secret_id = "publish-secret"
    }
  }
}

variable "gateway_service_secret_env_vars" {
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {
    SUPABASE_SECRET_KEY_PROD = {
      secret_id = "supabase-secret-key"
    }
    SUPABASE_SECRET_KEY_DEV = {
      secret_id = "supabase-secret-key-dev"
    }
  }
  
}
