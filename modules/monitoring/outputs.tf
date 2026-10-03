# ── Module: Log Analytics Workspace — Outputs ────────────────

output "workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "workspace_primary_key" {
  description = "Primary shared key for the workspace (used by legacy MMA agent)"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}
