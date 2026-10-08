# =============================================================================
# VIEW — groups task templates in the Semaphore UI.
# Includes _project.hcl (needs project_id) but NOT its own _view.hcl.
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "project" {
  path           = find_in_parent_folders("_project.hcl")
  merge_strategy = "deep"
}

terraform {
  source = "../../../../modules/semaphore/view"
}

inputs = {
  title    = "Deployments"
  position = 0
}
