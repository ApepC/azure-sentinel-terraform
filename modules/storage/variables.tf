# ── Module: Storage Account — Input Variables ────────────────

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

variable "frontend_subnet_id" {
  description = "Resource ID of the frontend subnet to allow storage access from"
  type        = string
}

variable "data_subnet_id" {
  description = "Resource ID of the data subnet to allow storage access from"
  type        = string
}

variable "log_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
}
