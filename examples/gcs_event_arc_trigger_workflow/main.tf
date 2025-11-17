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

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_binding" "pubsub" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  ]
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_project_iam_binding" "gcs" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  ]
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  members = [
    "serviceAccount:${data.google_compute_default_service_account.default.email}"
  ]

  lifecycle {
    ignore_changes = [members]
  }
}

resource "random_string" "string" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  numeric = false
}

module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.1.1"
  project_id = var.project_id
  prefix     = "eventarc-wf-${random_string.string.result}"
  names      = ["simple"]
  project_roles = ["${var.project_id}=>roles/workflows.invoker",
  "${var.project_id}=>roles/eventarc.serviceAgent",
  "${var.project_id}=>roles/eventarc.eventReceiver"]
}

module "gcs_buckets" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "~> 3.4.0"
  location        = "us-central1"
  project_id      = var.project_id
  names           = ["wf-bucket"]
  prefix          = random_string.string.result
  set_admin_roles = true
  admins          = ["serviceAccount:${data.google_compute_default_service_account.default.email}"]
  force_destroy   = { wf-bucket = true }
}

module "cloud_workflow" {
  source  = "GoogleCloudPlatform/cloud-workflows/google"
  version = "~> 0.1"

  project_id            = var.project_id
  workflow_name         = "wf-gcs-eventarc"
  region                = "us-central1"
  service_account_email = module.service_account.email
  workflow_trigger = {
    event_arc = {
      name                  = "trigger-gcs-workflow-tf"
      service_account_email = data.google_compute_default_service_account.default.email
      matching_criteria = [{
        attribute = "type"
        value     = "google.cloud.storage.object.v1.finalized"
        },
        {
          attribute = "bucket"
          value     = module.gcs_buckets.bucket.name
      }]
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
            - message: $${event.data.selfLink}
      - return_pubsub_message:
          return: $${message}
EOF

}
