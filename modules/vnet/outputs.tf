# ── Module: Virtual Network — Outputs ────────────────────────

output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet names to their resource IDs"
  value = {
    "snet-frontend"      = azurerm_subnet.frontend.id
    "snet-backend"       = azurerm_subnet.backend.id
    "snet-data"          = azurerm_subnet.data.id
    "snet-management"    = azurerm_subnet.management.id
    "AzureBastionSubnet" = azurerm_subnet.bastion.id
  }
}
