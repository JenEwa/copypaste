variable "project_id" {
  type = number
}

variable "view_id" {
  type = number
}

variable "repository_id" {
  type = number
}

variable "inventory_id" {
  type = number
}

variable "name" {
  type = string
}

variable "playbook" {
  type = string
}

# e.g. "ansible", "terraform", "opentofu", "bash", "powershell" —
# confirm the exact allowed values against the current provider docs.
variable "app" {
  type    = string
  default = "ansible"
}

resource "semaphore_project_template" "this" {
  project_id    = var.project_id
  view_id       = var.view_id
  repository_id = var.repository_id
  inventory_id  = var.inventory_id
  name          = var.name
  playbook      = var.playbook
  app           = var.app
}

output "id" {
  value = semaphore_project_template.this.id
}
