/**
 * Copyright 2021 Google LLC
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

output "workflow_id" {
  description = "The id  of the workflow."
  value       = module.cloud_workflow.workflow_id
}

output "workflow_revision_id" {
  description = "The revision id of the workflow."
  value       = module.cloud_workflow.workflow_revision_id
}

output "workflow_region" {
  description = "The id  of the workflow."
  value       = module.cloud_workflow.workflow_region
}

output "project_id" {
  description = "Google Cloud project in which the service was created"
  value       = var.project_id
}

output "event_arc_id" {
  description = "Google Cloud Event Arc id"
  value       = module.cloud_workflow.event_arc_id
}

output "pubsub_topic_id" {
  description = "Google Cloud Pubsub resource id"
  value       = module.cloud_workflow.pubsub_topic_id
}
