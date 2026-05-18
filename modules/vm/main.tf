# ── Module: Linux Virtual Machine ───────────────────────────
# Ubuntu 22.04 LTS, Trusted Launch, OMS agent,
# system-managed identity, no public IP, auto-shutdown

resource "azurerm_network_interface" "main" {
  name                = "nic-vm-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    # No public IP — access via Bastion only
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.main.id]

  # System-assigned managed identity for Key Vault access
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "osdisk-vm-${var.prefix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Trusted Launch — Secure Boot + vTPM
  secure_boot_enabled = true
  vtpm_enabled        = true

  boot_diagnostics {
    # Empty block = use managed storage account
  }

  patch_mode            = "AutomaticByPlatform"
  provision_vm_agent    = true
}

# ── OMS Agent → Log Analytics ────────────────────────────────
resource "azurerm_virtual_machine_extension" "oms" {
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.19"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    workspaceId = var.log_workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = var.log_workspace_key
  })
}

# ── Auto-shutdown (cost control) ─────────────────────────────
resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}
