# =============================================================================
# PROJECT — the root of the whole dependency tree.
# Does NOT include _project.hcl (it IS the project).
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/semaphore/project"
}

inputs = {
  name               = "prod"
  max_parallel_tasks = 0 # unlimited
}
