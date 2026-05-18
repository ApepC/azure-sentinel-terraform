# ── Module: Log Analytics Workspace ─────────────────────────

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = var.tags
}
