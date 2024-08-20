variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "workflow_name" {
  description = "The name of the workflow"
  type        = string
}

variable "region" {
  description = "The region where the workflow will be deployed"
  type        = string
}

variable "description" {
  description = "The description of the workflow"
  type        = string
  default     = "A simple workflow"
}

variable "service_account_id" {
  description = "The ID of the service account to associate with the workflow"
  type        = string
}

variable "workflow_call_log_level" {
  description = "The log level for workflow calls"
  type        = string
  default     = "LOG_ERRORS_ONLY"
}

variable "workflow_labels" {
  description = "Labels to apply to the workflow"
  type        = map(string)
  default     = {}
}

variable "workflow_user_env_vars" {
  description = "User-defined environment variables for the workflow"
  type        = map(string)
  default     = {}
}

variable "workflow_source" {
  description = "The source code of the workflow"
  type        = string
}