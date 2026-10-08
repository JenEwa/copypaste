# =============================================================================
# VIEW MARKER — included by every task (and its children) nested under this
# view's tasks/ folder. Resolves to THIS view's own terragrunt.hcl regardless
# of how deep the including file lives.
#
# Usage in a child terragrunt.hcl:
#   include "view" {
#     path           = find_in_parent_folders("_view.hcl")
#     merge_strategy = "deep"
#   }
#
# IMPORTANT: the view's OWN terragrunt.hcl (../terragrunt.hcl, one level up)
# must NOT include this file — that would make it depend on itself.
# =============================================================================

locals {
  view_dir = dirname(find_in_parent_folders("_view.hcl"))
}

dependency "view" {
  config_path  = local.view_dir
  mock_outputs = { id = 0 }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  view_id = dependency.view.outputs.id
}
