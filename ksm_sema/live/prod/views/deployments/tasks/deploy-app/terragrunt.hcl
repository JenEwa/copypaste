# =============================================================================
# TASK / TEMPLATE — the semaphore_project_template resource.
# Includes _project.hcl and _view.hcl (inherits project_id + view_id).
# Depends directly on its own ssh-keys/, repo/, inventory/ children.
# Does NOT include its own _task.hcl (only children do that).
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "project" {
  path           = find_in_parent_folders("_project.hcl")
  merge_strategy = "deep"
}

include "view" {
  path           = find_in_parent_folders("_view.hcl")
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../modules/semaphore/template"
}

dependency "key" {
  config_path  = "./ssh-keys/deploy-key"
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "repo" {
  config_path  = "./repo"
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "inventory" {
  config_path  = "./inventory"
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  repository_id = dependency.repo.outputs.id
  inventory_id  = dependency.inventory.outputs.id
  name          = "Deploy App"
  playbook      = "deploy.yml"
  app           = "ansible"
}
