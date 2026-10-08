variable "project_id" {
  type = number
}

variable "name" {
  type = string
}

variable "ssh_key_id" {
  type = number
}

variable "become_key_id" {
  type    = number
  default = null
}

# Simple static inventory. See the provider docs for static_yaml /
# terraform_workspace inventory types if you need those instead.
variable "static" {
  type = object({
    inventory = string
  })
  default = null
}

resource "semaphore_project_inventory" "this" {
  project_id     = var.project_id
  name           = var.name
  ssh_key_id     = var.ssh_key_id
  become_key_id  = var.become_key_id

  dynamic "static" {
    for_each = var.static != null ? [var.static] : []
    content {
      inventory = static.value.inventory
    }
  }
}

output "id" {
  value = semaphore_project_inventory.this.id
}
