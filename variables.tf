/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "workflow_name" {
  description = "The name of the cloud workflow to create"
  type        = string
}

variable "workflow_description" {
  description = "Description for the cloud workflow"
  type        = string
  default     = "Sample workflow Description"
}

variable "region" {
  description = "The name of the region where workflow will be created"
  type        = string
}

variable "workflow_source" {
  description = "Workflow YAML code to be executed. The size limit is 32KB."
  type        = string
}

variable "workflow_labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the workflow"
  default     = {}
}

variable "workflow_trigger" {
  type = object({
    cloud_scheduler = optional(object({
      name                  = string
      cron                  = string
      time_zone             = string
      deadline              = string
      argument              = optional(string)
      service_account_email = string
    }))
    event_arc = optional(object({
      name                  = string
      service_account_email = string
      matching_criteria = set(object({
        attribute = string
        operator  = optional(string)
        value     = string
      }))
      pubsub_topic_id = optional(string)
    }))
  })

  description = "Trigger for the Workflow . Cloud Scheduler OR Event Arc"
  validation {
    condition = !(
      var.workflow_trigger.cloud_scheduler == null
      &&
      var.workflow_trigger.event_arc == null
    )
    error_message = "Either cloud_scheduler OR event_arc information is supported."
  }
}

variable "service_account_email" {
  description = "Service account email. Unused if service account is auto-created."
  type        = string
  default     = null
}

variable "service_account_create" {
  description = "Auto-create service account."
  type        = bool
  default     = false
}

variable "call_log_level" {
  description = "Describe the level of platform logging to apply to calls and call responses during executions of this workflow. Possible values are: CALL_LOG_LEVEL_UNSPECIFIED, LOG_ALL_CALLS, LOG_ERRORS_ONLY, LOG_NONE."
  type        = string
  default     = "CALL_LOG_LEVEL_UNSPECIFIED"

  validation {
    condition     = contains(["CALL_LOG_LEVEL_UNSPECIFIED", "LOG_ALL_CALLS", "LOG_ERRORS_ONLY", "LOG_NONE"], var.call_log_level)
    error_message = "Invalid value for call_log_level. Possible values are: CALL_LOG_LEVEL_UNSPECIFIED, LOG_ALL_CALLS, LOG_ERRORS_ONLY, LOG_NONE."
  }
}

variable "execution_history_level" {
  description = "Describes the level of execution history to be stored for this workflow. Possible values are: EXECUTION_HISTORY_LEVEL_UNSPECIFIED, EXECUTION_HISTORY_BASIC, EXECUTION_HISTORY_DETAILED."
  type        = string
  default     = "EXECUTION_HISTORY_LEVEL_UNSPECIFIED"

  validation {
    condition     = contains(["EXECUTION_HISTORY_LEVEL_UNSPECIFIED", "EXECUTION_HISTORY_BASIC", "EXECUTION_HISTORY_DETAILED"], var.execution_history_level)
    error_message = "Invalid value for call_log_level. Possible values are: EXECUTION_HISTORY_LEVEL_UNSPECIFIED, EXECUTION_HISTORY_BASIC, EXECUTION_HISTORY_DETAILED."
  }
}

variable "user_env_vars" {
  description = "User-defined environment variables associated with this workflow revision. This map has a maximum length of 20. Each string can take up to 4KiB. Keys cannot be empty strings and cannot start with \"GOOGLE\" or \"WORKFLOWS\"."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Whether Terraform will be prevented from destroying the workflow. Defaults to true."
  type        = bool
  default     = null
}
