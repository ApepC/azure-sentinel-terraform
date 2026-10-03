# ── Root Variables ───────────────────────────────────────────

variable "environment" {
  description = "Deployment environment: dev, staging, prod"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Short project name used as resource prefix (2-8 lowercase alphanumeric chars)"
  type        = string
  default     = "sentinel"
  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.project_name))
    error_message = "Project name must be 2-8 lowercase alphanumeric characters (a-z, 0-9)."
  }
}

variable "owner" {
  description = "Owner tag value — your name or team"
  type        = string
  default     = "C Solo"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "vnet_address_space must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "subnets" {
  description = "Map of subnet names to address prefixes"
  type        = map(string)
  default = {
    "snet-frontend"      = "10.0.1.0/24"
    "snet-backend"       = "10.0.2.0/24"
    "snet-data"          = "10.0.3.0/24"
    "snet-management"    = "10.0.4.0/24"
    "AzureBastionSubnet" = "10.0.5.0/26"
  }
}

variable "allowed_admin_cidr" {
  description = "Your IP in CIDR notation for NSG admin allow-list (e.g. 203.0.113.5/32)"
  type        = string
  validation {
    condition     = can(cidrhost(var.allowed_admin_cidr, 0))
    error_message = "allowed_admin_cidr must be a valid CIDR block (e.g. 203.0.113.5/32)."
  }
}

variable "deploy_vm" {
  description = "Deploy a demo Linux VM into the management subnet?"
  type        = bool
  default     = false
}

variable "admin_username" {
  description = "VM administrator username"
  type        = string
  default     = "azureadmin"
  validation {
    condition     = can(regex("^[a-z][a-z0-9_-]{2,19}$", var.admin_username))
    error_message = "admin_username must start with a letter and be 3-20 characters (a-z, 0-9, -, _)."
  }
}

variable "admin_password" {
  description = "VM administrator password (required if deploy_vm = true, min 12 chars)"
  type        = string
  sensitive   = true
  default     = ""
  validation {
    condition     = var.admin_password == "" || length(var.admin_password) >= 12
    error_message = "admin_password must be at least 12 characters when set."
  }
}

variable "vm_size" {
  description = "Azure VM size for the demo VM"
  type        = string
  default     = "Standard_B2s"
  validation {
    condition     = contains(["Standard_B2s", "Standard_B4ms", "Standard_D2s_v5"], var.vm_size)
    error_message = "vm_size must be Standard_B2s, Standard_B4ms, or Standard_D2s_v5."
  }
}
