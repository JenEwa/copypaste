terraform {
  # Write-only arguments need Terraform >= 1.11 (or OpenTofu >= 1.11).
  required_version = ">= 1.11"

  required_providers {
    semaphoreui = {
      source  = "semaphoreui/semaphore"
      version = ">= 0.3.10, < 0.4.0" # 0.3.10 added secrets[].value_wo
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.4.0" # 1.4.0 added secretsmanager_metadata.revision
    }
  }
}
