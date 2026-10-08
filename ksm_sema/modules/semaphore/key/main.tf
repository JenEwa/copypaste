variable "project_id" {
  type = number
}

variable "name" {
  type = string
}

# "ssh", "login_password", or "none" — check the current provider docs for
# the exact set of supported types and their nested attribute blocks.
variable "type" {
  type = string
}

variable "ssh" {
  type = object({
    private_key = optional(string)
    passphrase  = optional(string)
  })
  default = null
}

variable "login_password" {
  type = object({
    login    = optional(string)
    password = optional(string)
  })
  default = null
}

resource "semaphore_project_key" "this" {
  project_id = var.project_id
  name       = var.name

  dynamic "ssh" {
    for_each = var.type == "ssh" ? [var.ssh] : []
    content {
      private_key = ssh.value.private_key
      passphrase  = ssh.value.passphrase
    }
  }

  dynamic "login_password" {
    for_each = var.type == "login_password" ? [var.login_password] : []
    content {
      login    = login_password.value.login
      password = login_password.value.password
    }
  }

  dynamic "none" {
    for_each = var.type == "none" ? [1] : []
    content {}
  }
}

output "id" {
  value = semaphore_project_key.this.id
}
