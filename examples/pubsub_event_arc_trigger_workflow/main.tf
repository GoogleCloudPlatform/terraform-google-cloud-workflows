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
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_pubsub_topic" "event_arc" {
  name    = "test-pubsub-topic"
  project = var.project_id
}

module "service_account" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.1.1"
  project_id    = var.project_id
  prefix        = "eventarc-workflow"
  names         = ["simple"]
  project_roles = ["${var.project_id}=>roles/workflows.invoker"]
}

module "cloud_workflow" {
  source                = "../.."
  project_id            = var.project_id
  workflow_name         = "wf-pubsub-eventarc"
  region                = "us-central1"
  service_account_email = module.service_account.email
  workflow_trigger = {
    event_arc = {
      name                  = "trigger-pubsub-workflow-tf"
      service_account_email = data.google_compute_default_service_account.default.email
      matching_criteria = [{
        attribute = "type"
        value     = "google.cloud.pubsub.topic.v1.messagePublished"
      }]
      pubsub_topic_id = google_pubsub_topic.event_arc.id
    }
  }
  workflow_source = <<-EOF
  # This is a sample workflow that simply logs the incoming Pub/Sub event
  # Note that $$ is needed for Terraform

  main:
    params: [event]
    steps:
      - decode_pubsub_message:
          assign:
            - base64: $${base64.decode(event.data.message.data)}
            - message: $${text.decode(base64)}
      - return_pubsub_message:
          return: $${message}
EOF

}
