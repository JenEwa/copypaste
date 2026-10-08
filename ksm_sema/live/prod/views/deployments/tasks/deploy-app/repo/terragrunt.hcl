# =============================================================================
# REPOSITORY — belongs to the deploy-app task.
# Includes _project.hcl, and locates its sibling key via _task.hcl so the
# path is correct no matter how deep this file lives.
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "project" {
  path           = find_in_parent_folders("_project.hcl")
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../modules/semaphore/repository"
}

locals {
  task_dir = dirname(find_in_parent_folders("_task.hcl"))
}

dependency "key" {
  config_path  = "${local.task_dir}/ssh-keys/deploy-key"
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  ssh_key_id = dependency.key.outputs.id
  name       = "app-repo"
  url        = "git@github.com:myorg/app.git"
  branch     = "main"
}
