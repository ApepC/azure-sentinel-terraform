# ============================================================
# Azure Sentinel Infrastructure — Terraform Root Module
# AZ-104 / Terraform Associate Portfolio Project | CS
# ============================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # ── Remote State Backend ───────────────────────────────────
  # To enable remote state:
  #   1. Run ./scripts/bootstrap-state.sh
  #   2. Copy the backend block it prints below (uncomment it)
  #   3. Run: terraform init -reconfigure
  #
  # Leaving this commented keeps state local (terraform.tfstate in the
  # project root). Fine for a solo demo, NOT for team use.
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "stsentinelXXXXXX"   # from bootstrap script
  #   container_name       = "tfstate"
  #   key                  = "sentinel.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = var.environment != "prod"
      recover_soft_deleted_key_vaults = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
      graceful_shutdown          = true
    }
    resource_group {
      # Set to false so `terraform destroy` cleanly tears down the demo.
      # Production should use true to prevent accidental data loss.
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ── Random suffix for globally unique names ──────────────────
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  prefix = "${var.project_name}-${var.environment}"
  suffix = random_string.suffix.result
  common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    owner       = var.owner
  })
}

# ── Resource Group ───────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.common_tags
}

# ── Monitoring (deployed first — all others send logs here) ──
module "monitoring" {
  source = "./modules/monitoring"

  prefix              = local.prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
  retention_days      = var.environment == "prod" ? 90 : 30
}

# ── Sentinel Onboarding ──────────────────────────────────────
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = module.monitoring.workspace_id
}

# ── Virtual Network ──────────────────────────────────────────
module "vnet" {
  source = "./modules/vnet"

  prefix              = local.prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  allowed_admin_cidr  = var.allowed_admin_cidr
}

# ── Storage Account ──────────────────────────────────────────
module "storage" {
  source = "./modules/storage"

  prefix              = local.prefix
  suffix              = local.suffix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
  environment         = var.environment
  frontend_subnet_id  = module.vnet.subnet_ids["snet-frontend"]
  data_subnet_id      = module.vnet.subnet_ids["snet-data"]
  log_workspace_id    = module.monitoring.workspace_id
}

# ── Key Vault ────────────────────────────────────────────────
module "keyvault" {
  source = "./modules/keyvault"

  prefix                = local.prefix
  suffix                = local.suffix
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  tags                  = local.common_tags
  environment           = var.environment
  backend_subnet_id     = module.vnet.subnet_ids["snet-backend"]
  log_workspace_id      = module.monitoring.workspace_id
  soft_delete_retention = var.environment == "prod" ? 90 : 7
  purge_protection      = var.environment == "prod"
}

# ── Virtual Machine (optional) ───────────────────────────────
module "vm" {
  source = "./modules/vm"
  count  = var.deploy_vm ? 1 : 0

  prefix              = local.prefix
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
  subnet_id           = module.vnet.subnet_ids["snet-management"]
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.vm_size
  log_workspace_id    = module.monitoring.workspace_id
  log_workspace_key   = module.monitoring.workspace_primary_key

  lifecycle {
    precondition {
      condition     = !var.deploy_vm || length(var.admin_password) >= 12
      error_message = "admin_password must be at least 12 characters when deploy_vm = true."
    }
  }
}
