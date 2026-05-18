variable "prefix"              { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "tags"                { type = map(string) }
variable "vnet_address_space"  { type = string }
variable "subnets"             { type = map(string) }
variable "allowed_admin_cidr"  { type = string; sensitive = true }
