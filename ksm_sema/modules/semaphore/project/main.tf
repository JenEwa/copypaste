variable "name" {
  type = string
}

variable "max_parallel_tasks" {
  type    = number
  default = 0
}

variable "alert" {
  type    = bool
  default = false
}

resource "semaphore_project" "this" {
  name               = var.name
  max_parallel_tasks = var.max_parallel_tasks
  alert              = var.alert
}

output "id" {
  value = semaphore_project.this.id
}
