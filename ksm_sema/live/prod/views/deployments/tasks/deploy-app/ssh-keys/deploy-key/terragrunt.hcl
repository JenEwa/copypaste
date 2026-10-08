# =============================================================================
# KEY — belongs to the deploy-app task. Includes _project.hcl for project_id.
# Does NOT need _view.hcl or _task.hcl — it has no children of its own.
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "project" {
  path           = find_in_parent_folders("_project.hcl")
  merge_strategy = "deep"
}

terraform {
  source = "../../../../../../../../modules/semaphore/key"
}

inputs = {
  name = "deploy-key"
  type = "ssh"
  # Real deployments should pull the private key from a secret store
  # (e.g. AWS Secrets Manager / Vault) rather than committing it here.
  # ssh = {
  #   private_key = data.aws_secretsmanager_secret_version.deploy_key.secret_string
  # }
}
