# Semaphore environment with secrets from Keeper (ephemeral)

Terragrunt creates a Semaphore environment whose secrets are read from Keeper
Secrets Manager at apply time. The values never land in Terraform state or
plan files:

- Keeper values are read with the **ephemeral** `secretsmanager_field` resource.
- They are passed to Semaphore through the **write-only** `secrets[].value_wo`
  argument of the official provider `semaphoreui/semaphore` (>= 0.3.10).
- `value_wo_version` is the Keeper record's `revision`, so changing a secret in
  Keeper makes the next `terragrunt apply` push the new value.

```
modules/semaphore-environment/    Terraform module
live/root.hcl                     Terragrunt root: providers + backend
live/prod/semaphore-environment/  Terragrunt unit
```

## Requirements

- Terraform >= 1.11 or OpenTofu >= 1.11 (write-only arguments)
- `semaphoreui/semaphore` >= 0.3.10
- `keeper-security/secretsmanager` >= 1.4.0

## Usage

```bash
export SEMAPHOREUI_API_BASE_URL=https://semaphore.example.com/api
export SEMAPHOREUI_API_TOKEN=...
export KEEPER_CREDENTIAL="$(cat ~/.keeper/credential)"   # base64 KSM config

cd live/prod/semaphore-environment
terragrunt apply
```

The KSM application only needs **read** access to the records you reference.

## What is still in state

- Secret names, types and `value_wo_version` (the Keeper record revision).
- From `secretsmanager_metadata`: record UID, title, type, folder UID and
  **notes**. Don't keep secrets in the notes of these records.

## Rotation

Change the value in Keeper → record revision increases → next apply sees a new
`value_wo_version` and re-sends `value_wo`. Editing the record title or notes
also bumps the revision; that just re-sends the same value.

## Migrating from CruGlobal/semaphoreui

The official provider is a fork with the same resource names (`semaphoreui_*`),
so you can switch the provider source in state instead of recreating:

```bash
terragrunt state replace-provider \
  registry.terraform.io/cruglobal/semaphoreui \
  registry.terraform.io/semaphoreui/semaphore
```

Run `terragrunt plan` afterwards and check that nothing is replaced.

Note the provider config changed: `hostname`/`port`/`protocol`/`path` are
replaced by a single `api_base_url` (`SEMAPHOREUI_API_BASE_URL`).

The secret values from the old setup are still in your **older state
versions** (GitLab keeps state history). Once you've switched, rotate those
secrets in Keeper; the next apply pushes the new values and nothing readable
is left behind.
