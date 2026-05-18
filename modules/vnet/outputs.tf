output "vnet_id"   { value = azurerm_virtual_network.main.id }
output "vnet_name" { value = azurerm_virtual_network.main.name }

output "subnet_ids" {
  description = "Map of subnet name → resource ID"
  value = {
    "snet-frontend"      = azurerm_subnet.frontend.id
    "snet-backend"       = azurerm_subnet.backend.id
    "snet-data"          = azurerm_subnet.data.id
    "snet-management"    = azurerm_subnet.management.id
    "AzureBastionSubnet" = azurerm_subnet.bastion.id
  }
}

output "nsg_ids" {
  description = "Map of NSG name → resource ID"
  value = {
    frontend   = azurerm_network_security_group.frontend.id
    backend    = azurerm_network_security_group.backend.id
    data       = azurerm_network_security_group.data.id
    management = azurerm_network_security_group.management.id
  }
}
