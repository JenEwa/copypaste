# =============================================================================
# TASK MARKER — included by everything nested under this task
# (ssh-keys/, repo/, inventory/), so those leaves can find their way back to
# THIS task's own directory without hardcoding depth via dirname(dirname(...)).
#
# Usage in a leaf terragrunt.hcl:
#   locals {
#     task_dir = dirname(find_in_parent_folders("_task.hcl"))
#   }
#
# This file intentionally does NOT declare a `dependency` block itself — the
# task's own terragrunt.hcl depends on ITS children (key/repo/inventory), so
# the relationship runs the opposite direction from _project.hcl / _view.hcl.
# Leaves use `task_dir` to reach sibling folders, e.g.:
#   dependency "key" { config_path = "${local.task_dir}/ssh-keys/deploy-key" }
#
# IMPORTANT: the task's OWN terragrunt.hcl (one level up) must NOT include
# this file — only its children should.
# =============================================================================
