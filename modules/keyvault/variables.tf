# ── Module: Key Vault — Input Variables ──────────────────────

variable "prefix" {
  description = "Naming prefix applied to all resources (e.g. sentinel-dev)"
  type        = string
}

variable "suffix" {
  description = "Random suffix for globally unique resource names"
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

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "backend_subnet_id" {
  description = "Resource ID of the backend subnet allowed to reach Key Vault"
  type        = string
}

variable "log_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
}

variable "soft_delete_retention" {
  description = "Soft delete retention in days (7-90)"
  type        = number
  default     = 7
  validation {
    condition     = var.soft_delete_retention >= 7 && var.soft_delete_retention <= 90
    error_message = "soft_delete_retention must be between 7 and 90 days."
  }
}

variable "purge_protection" {
  description = "Enable purge protection (irreversible — cannot be disabled after creation)"
  type        = bool
  default     = false
}
