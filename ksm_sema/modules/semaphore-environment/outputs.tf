output "id" {
  description = "Semaphore environment ID, for use in templates."
  value       = semaphoreui_project_environment.this.id
}
