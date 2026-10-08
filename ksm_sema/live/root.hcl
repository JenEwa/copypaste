# Shared Terragrunt config. Child units include this with find_in_parent_folders("root.hcl").
#
# Credentials come from the environment:
#   SEMAPHOREUI_API_BASE_URL  e.g. https://semaphore.example.com/api
#   SEMAPHOREUI_API_TOKEN
#   KEEPER_CREDENTIAL         base64 KSM config

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "semaphoreui" {}
    provider "secretsmanager" {}
  EOF
}

# Point this at your existing backend (e.g. GitLab-managed Terraform state).
remote_state {
  backend = "http"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    address        = "https://gitlab.example.com/api/v4/projects/<PROJECT_ID>/terraform/state/${replace(path_relative_to_include(), "/", "-")}"
    lock_address   = "https://gitlab.example.com/api/v4/projects/<PROJECT_ID>/terraform/state/${replace(path_relative_to_include(), "/", "-")}/lock"
    unlock_address = "https://gitlab.example.com/api/v4/projects/<PROJECT_ID>/terraform/state/${replace(path_relative_to_include(), "/", "-")}/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }
}
