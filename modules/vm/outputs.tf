output "vm_id" {
  description = "Resource ID of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "principal_id" {
  description = "Principal ID of the VM's system-assigned managed identity"
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
}

output "private_ip" {
  description = "Private IP address of the VM's network interface"
  value       = azurerm_network_interface.main.private_ip_address
}

output "nic_id" {
  description = "Resource ID of the VM's network interface"
  value       = azurerm_network_interface.main.id
}
