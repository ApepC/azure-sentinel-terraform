# ── Module: Key Vault ────────────────────────────────────────

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.prefix}-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  tags                       = var.tags

  # RBAC over legacy access policies — AZ-104 best practice
  enable_rbac_authorization  = true
  soft_delete_retention_days = var.soft_delete_retention
  purge_protection_enabled   = var.purge_protection

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [var.backend_subnet_id]
  }
}

# ── Diagnostic Settings ───────────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-kv-${var.prefix}"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log { category = "AuditEvent" }
  enabled_log { category = "AzurePolicyEvaluationDetails" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
