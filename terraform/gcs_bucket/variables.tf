variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "lifecycle_rules" {
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
    })
  }))
  default = []
}
