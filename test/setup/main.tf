/**
 * Copyright 2019 Google LLC
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

locals {
  per_module_services = {
    simple_workflow = [
      "iam.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "workflows.googleapis.com",
      "logging.googleapis.com",
      "storage.googleapis.com",
    ],
    root = [
      "iam.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "storage-api.googleapis.com",
      "serviceusage.googleapis.com",
      "workflows.googleapis.com",
      "cloudscheduler.googleapis.com",
      "eventarc.googleapis.com",
      "pubsub.googleapis.com",
      "logging.googleapis.com",
      "storage.googleapis.com",
    ]
  }
}

module "project" {
  source                  = "terraform-google-modules/project-factory/google"
  version                 = "~> 13.0"
  name                    = "ci-cloud-workflow"
  random_project_id       = "true"
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  default_service_account = "keep"
  activate_apis           = flatten(values(local.per_module_services))
}

resource "google_project_service_identity" "eventarc_sa" {
  provider = google-beta
  project  = module.project.project_id
  service  = "eventarc.googleapis.com"

  depends_on = [module.project]
}

# Wait after service identity is created to allow for propagation.
resource "time_sleep" "wait_after_eventarc_sa_creation" {
  create_duration = "60s"

  depends_on = [google_project_service_identity.eventarc_sa]
}

resource "google_project_iam_member" "eventarc_service_agent" {
  project = module.project.project_id
  role    = "roles/eventarc.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.eventarc_sa.email}"

  depends_on = [time_sleep.wait_after_eventarc_sa_creation]
}

resource "google_project_service_identity" "workflow_sa" {
  provider = google-beta
  project  = module.project.project_id
  service  = "workflows.googleapis.com"

  depends_on = [module.project]
}

# Wait after service identity is created to allow for propagation.
resource "time_sleep" "wait_after_workflow_sa_creation" {
  create_duration = "60s"

  depends_on = [google_project_service_identity.workflow_sa]
}

resource "google_project_iam_member" "workflow_service_agent" {
  project = module.project.project_id
  role    = "roles/workflows.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.workflow_sa.email}"

  depends_on = [time_sleep.wait_after_workflow_sa_creation]
}

# Wait after APIs are enabled to give time for them to spin up
resource "time_sleep" "wait_after_apis" {
  create_duration = "240s"
  depends_on      = [module.project]
}
