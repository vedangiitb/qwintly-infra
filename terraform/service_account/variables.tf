variable "account_id" {
  type = string
}

variable "display_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_roles" {
  type    = set(string)
  default = []
}
