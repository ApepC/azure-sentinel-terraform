# ── Module: Log Analytics Workspace ─────────────────────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags

  # Cost control — cap ingestion in non-prod. Set to -1 for unlimited.
  daily_quota_gb = var.environment == "prod" ? -1 : 1

  # Legacy MMA agent (deployed by the vm module) requires shared-key auth.
  # Set to false after migrating to Azure Monitor Agent (AMA) + DCR.
  local_authentication_enabled = true
}
