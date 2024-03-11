variable "azure_firewall_policy_list" {
  type        = list(any)
  default     = []
  description = "list of azure firewall policy objects "
}

variable "resource_group_output" {
  type        = map(any)
  default     = {}
  description = "list of resource group objects "
}

variable "log_analytics_workspace_output" {
  type        = map(any)
  default     = {}
  description = "list of log analytics workspace objects "
}

variable "user_identity_output" {
  type        = map(any)
  default     = {}
  description = "list of user identity output objects "
}

variable "default_values" {
  type = any
  default = {}
  description = "Provide default values for resource if not any"  
}