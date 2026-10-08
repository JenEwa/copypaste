variable "project_id" {
  type = number
}

variable "name" {
  type = string
}

variable "url" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "ssh_key_id" {
  type = number
}

resource "semaphore_project_repository" "this" {
  project_id = var.project_id
  name       = var.name
  url        = var.url
  branch     = var.branch
  ssh_key_id = var.ssh_key_id
}

output "id" {
  value = semaphore_project_repository.this.id
}
