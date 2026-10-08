# =============================================================================
# PROJECT MARKER — included by EVERY unit under live/prod (directly or via
# _view.hcl / _task.hcl), no matter how deep it lives.
#
# Usage in a child terragrunt.hcl:
#   include "project" {
#     path           = find_in_parent_folders("_project.hcl")
#     merge_strategy = "deep"
#   }
#
# This gives the child `project_id` for free via the merged `inputs` block.
#
# IMPORTANT: the project's OWN terragrunt.hcl (live/prod/project/terragrunt.hcl)
# must NOT include this file — that would make it depend on itself.
# =============================================================================

locals {
  project_dir = "${dirname(find_in_parent_folders("_project.hcl"))}/project"
}

dependency "project" {
  config_path  = local.project_dir
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_id = dependency.project.outputs.id
}
