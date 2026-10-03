# ── Module: Virtual Network — Input Variables ────────────────

variable "prefix" {
  description = "Naming prefix applied to all resources (e.g. sentinel-dev)"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (e.g. 10.0.0.0/16)"
  type        = string
  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "vnet_address_space must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "subnets" {
  description = "Map of subnet names to their address prefixes"
  type        = map(string)
}

variable "allowed_admin_cidr" {
  description = "Admin IP in CIDR notation for the management NSG allow-list (e.g. 203.0.113.5/32)"
  type        = string
  validation {
    condition     = can(cidrhost(var.allowed_admin_cidr, 0))
    error_message = "allowed_admin_cidr must be a valid CIDR block (e.g. 203.0.113.5/32)."
  }
}
