# ── Module: Virtual Network ──────────────────────────────────
# Deploys: Hub VNet, tiered NSGs, subnets with service endpoints

# ── NSG: Frontend ────────────────────────────────────────────
resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-frontend-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "frontend_https" {
  name                        = "Allow-HTTPS-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  description                 = "Allow HTTPS from internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_network_security_rule" "frontend_http" {
  name                        = "Allow-HTTP-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  description                 = "Allow HTTP — redirect to HTTPS at app layer"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_network_security_rule" "frontend_deny_all" {
  name                        = "Deny-All-Other-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Default deny all other inbound"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

# ── NSG: Backend ─────────────────────────────────────────────
resource "azurerm_network_security_group" "backend" {
  name                = "nsg-backend-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "backend_from_frontend" {
  name                        = "Allow-Frontend-To-Backend"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = var.subnets["snet-frontend"]
  destination_address_prefix  = "*"
  description                 = "Allow frontend subnet to reach backend API"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.backend.name
}

resource "azurerm_network_security_rule" "backend_deny_internet" {
  name                        = "Deny-Internet-Inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  description                 = "Block all direct internet access to backend"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.backend.name
}

# ── NSG: Data ────────────────────────────────────────────────
resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "data_from_backend" {
  name                        = "Allow-Backend-To-Data"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = var.subnets["snet-backend"]
  destination_address_prefix  = "*"
  description                 = "Allow backend subnet to reach SQL data layer"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

resource "azurerm_network_security_rule" "data_deny_all" {
  name                        = "Deny-All-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Strict deny all — data tier never exposed"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

# ── NSG: Management ──────────────────────────────────────────
resource "azurerm_network_security_group" "management" {
  name                = "nsg-mgmt-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "mgmt_admin_ssh_rdp" {
  name                        = "Allow-Admin-SSH-RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = var.allowed_admin_cidr
  destination_address_prefix  = "*"
  description                 = "Allow SSH/RDP from admin IP only"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management.name
}

resource "azurerm_network_security_rule" "mgmt_deny_all" {
  name                        = "Deny-All-Other-Management"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management.name
}

# ── Virtual Network ──────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# ── Subnets ──────────────────────────────────────────────────
resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets["snet-frontend"]]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets["snet-backend"]]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets["snet-data"]]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets["snet-management"]]
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_subnet" "bastion" {
  # Bastion subnet must be named exactly "AzureBastionSubnet"
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets["AzureBastionSubnet"]]
  # No NSG — Bastion manages its own security
}
