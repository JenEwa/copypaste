variable "project_id" {
  description = "Semaphore project ID the environment belongs to."
  type        = number
}

variable "name" {
  description = "Display name of the Semaphore environment."
  type        = string
}

variable "extra_vars" {
  description = "Non-secret extra vars."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Non-secret environment variables."
  type        = map(string)
  default     = {}
}

variable "keeper_secrets" {
  description = <<-EOT
    Semaphore secret name => where to read it in Keeper.

      uid          Keeper record UID
      field        standard field type, e.g. "password", "login"   (one of field /
      custom_field custom field label                               custom_field)
      type         "env" (environment variable, default) or "var" (extra var)
  EOT
  type = map(object({
    uid          = string
    field        = optional(string)
    custom_field = optional(string)
    type         = optional(string, "env")
  }))
  default = {}

  validation {
    condition = alltrue([
      for s in values(var.keeper_secrets) : (s.field == null) != (s.custom_field == null)
    ])
    error_message = "Each keeper_secrets entry needs exactly one of `field` or `custom_field`."
  }

  validation {
    condition     = alltrue([for s in values(var.keeper_secrets) : contains(["env", "var"], s.type)])
    error_message = "keeper_secrets[*].type must be \"env\" or \"var\"."
  }
}
