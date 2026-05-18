variable "prefix"              { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "tags"                { type = map(string) }
variable "subnet_id"           { type = string }
variable "admin_username"      { type = string }
variable "admin_password"      { type = string; sensitive = true }
variable "vm_size"             { type = string; default = "Standard_B2s" }
variable "log_workspace_id"    { type = string }
variable "log_workspace_key"   { type = string; sensitive = true }
