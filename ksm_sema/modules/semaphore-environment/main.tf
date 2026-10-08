locals {
  keeper_paths = {
    for name, s in var.keeper_secrets : name => (
      s.field != null
      ? "${s.uid}/field/${s.field}"
      : "${s.uid}/custom_field/${s.custom_field}"
    )
  }

  keeper_record_uids = toset([for s in values(var.keeper_secrets) : s.uid])
}

# Secret values: read during plan/apply only, never written to state or plan.
ephemeral "secretsmanager_field" "secret" {
  for_each = local.keeper_paths
  path     = each.value
}

# Non-secret record metadata. `revision` increments whenever the record
# changes, which drives value_wo_version below, so rotating a secret in
# Keeper is picked up by the next apply.
#
# Note: this data source stores the record's title and notes in state.
# Don't put secrets in the notes of records used here.
data "secretsmanager_metadata" "record" {
  for_each = local.keeper_record_uids
  path     = each.value
}

resource "semaphoreui_project_environment" "this" {
  project_id  = var.project_id
  name        = var.name
  variables   = var.extra_vars
  environment = var.environment

  secrets = [
    for name, s in var.keeper_secrets : {
      name             = name
      type             = s.type
      value_wo         = ephemeral.secretsmanager_field.secret[name].value
      value_wo_version = data.secretsmanager_metadata.record[s.uid].revision
    }
  ]
}
