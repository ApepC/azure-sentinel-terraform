output "workspace_id"          { value = azurerm_log_analytics_workspace.main.id }
output "workspace_name"        { value = azurerm_log_analytics_workspace.main.name }
output "workspace_primary_key" {
  value     = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive = true
}
