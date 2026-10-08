# =============================================================================
# ROOT CONFIG — included by every unit in this tree via:
#   include "root" { path = find_in_parent_folders("root.hcl") }
#
# Named root.hcl (not terragrunt.hcl) on purpose: it lets find_in_parent_folders()
# search for OTHER marker files (_project.hcl, _view.hcl, _task.hcl) without ever
# colliding with this file's own name.
# =============================================================================

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "my-tfstate-bucket"
    key            = "semaphore/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    semaphore = {
      source  = "semaphoreui/semaphore"
      version = "~> 0.3"
    }
  }
}

provider "semaphore" {
  server_url = "${get_env("SEMAPHORE_URL")}"
  api_token  = "${get_env("SEMAPHORE_API_TOKEN")}"
}
EOF
}
