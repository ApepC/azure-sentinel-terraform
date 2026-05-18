# ── Root Outputs ─────────────────────────────────────────────

output "resource_group_name" {
  description = "Name of the deployed resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to resource IDs"
  value       = module.vnet.subnet_ids
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.storage.storage_account_name
}

output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = module.storage.storage_account_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.key_vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = module.keyvault.key_vault_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = module.monitoring.workspace_id
}

output "vm_id" {
  description = "Resource ID of the demo VM (if deployed)"
  value       = var.deploy_vm ? module.vm[0].vm_id : null
}

output "vm_principal_id" {
  description = "Managed Identity principal ID of the VM (if deployed)"
  value       = var.deploy_vm ? module.vm[0].principal_id : null
}
