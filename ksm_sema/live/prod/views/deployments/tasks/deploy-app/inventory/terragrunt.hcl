# =============================================================================
# INVENTORY — belongs to the deploy-app task.
# Includes _project.hcl, and locates its sibling key via _task.hcl.
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "project" {
  path           = find_in_parent_folders("_project.hcl")
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../modules/semaphore/inventory"
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
  name       = "prod-hosts"
  static = {
    inventory = "app01.prod.internal ansible_user=deploy\napp02.prod.internal ansible_user=deploy\n"
  }
}
