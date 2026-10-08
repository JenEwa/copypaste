include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/semaphore-environment"
}

inputs = {
  project_id = 1
  name       = "production"

  extra_vars = {
    app_env = "prod"
  }

  environment = {
    TZ = "Europe/Berlin"
  }

  # Semaphore secret name => Keeper reference. Only references live here.
  keeper_secrets = {
    DB_USER     = { uid = "AbC123xyzRecordUid", field = "login" }
    DB_PASSWORD = { uid = "AbC123xyzRecordUid", field = "password" }
    API_TOKEN   = { uid = "XyZ987abcRecordUid", custom_field = "api_token" }

    # Secret extra var instead of env var:
    vault_password = { uid = "QwE456rtyRecordUid", field = "password", type = "var" }
  }
}
