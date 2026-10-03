# ── Module: Log Analytics Workspace — Input Variables ────────

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

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "retention_days" {
  description = "Log retention in days (30-730 depending on pricing tier)"
  type        = number
  default     = 30
  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "retention_days must be between 30 and 730."
  }
}
