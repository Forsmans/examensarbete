variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "westeurope"
}

variable "excluded_policy_definitions" {
  type        = list(string)
  description = "Policies Definitions from .alzlib to exclude"
  default     = []
}

variable "excluded_policy_set_definitions" {
  type        = list(string)
  description = "Policies Set Definitions from .alzlib to exclude"
  default     = []
}

variable "root_management_group_id" {
  type        = string
  description = "The root group where the definitions will be created"
}

variable "policy_assignments_by_scope" {
  type        = map(map(string))
  description = "Mapping of scope to list of policy names"
  default     = {}
}

variable "policy_exclusions_by_scope" {
  type        = map(map(list(string)))
  description = "Mapping of scope to list of policy exclusions (policy_name = [excluded_scopes])"
  default     = {}
}

variable "policy_set_assignments_by_scope" {
  type        = map(map(string))
  description = "Mapping of scope to list of policy set names"
  default     = {}
}
