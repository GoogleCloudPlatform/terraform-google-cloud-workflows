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

variable "cloud_scheduler_name" {
  description = "Cloud Scheduler Name"
  type        = string
}

variable "cloud_scheduler_cron" {
  description = "Cron which represents the schedule on which the Cloud Scheduler Job will be executed."
  type        = string
}

variable "cloud_scheduler_time_zone" {
  description = "Cloud Scheduler Time Zone."
  type        = string
}

variable "cloud_scheduler_deadline" {
  description = "Cloud Scheduler Time Zone."
  type        = string
}

variable "service_account_email" {
  type        = string
  description = "Service Account email needed for the service"
  default     = ""
}
