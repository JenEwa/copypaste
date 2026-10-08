variable "project_id" {
  type = number
}

variable "title" {
  type = string
}

variable "position" {
  type    = number
  default = 0
}

resource "semaphore_project_view" "this" {
  project_id = var.project_id
  title      = var.title
  position   = var.position
}

output "id" {
  value = semaphore_project_view.this.id
}
