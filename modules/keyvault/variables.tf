variable "prefix"                { type = string }
variable "suffix"                { type = string }
variable "location"              { type = string }
variable "resource_group_name"   { type = string }
variable "tags"                  { type = map(string) }
variable "environment"           { type = string }
variable "backend_subnet_id"     { type = string }
variable "log_workspace_id"      { type = string }
variable "soft_delete_retention" { type = number; default = 7 }
variable "purge_protection"      { type = bool;   default = false }
