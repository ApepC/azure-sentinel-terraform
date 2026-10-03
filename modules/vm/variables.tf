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

variable "subnet_id" {
  description = "Resource ID of the subnet to attach the VM's NIC to"
  type        = string
}

variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Administrator password for the VM (min 12 characters)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "admin_password must be at least 12 characters."
  }
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "log_workspace_id" {
  description = "Log Analytics Workspace ID for the OMS agent"
  type        = string
}

variable "log_workspace_key" {
  description = "Log Analytics Workspace primary key for the OMS agent"
  type        = string
  sensitive   = true
}
