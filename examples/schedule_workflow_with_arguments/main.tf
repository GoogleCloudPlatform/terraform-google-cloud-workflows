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

module "service_account" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.2.0"
  project_id    = var.project_id
  prefix        = "sa-workflow-with-args"
  names         = ["simple"]
  project_roles = ["${var.project_id}=>roles/workflows.invoker"]
}

module "cloud_workflow" {
  source  = "GoogleCloudPlatform/cloud-workflows/google"
  version = "~> 0.1"

  project_id            = var.project_id
  workflow_name         = "wf-sample-with-args"
  region                = "us-central1"
  service_account_email = module.service_account.email
  workflow_trigger = {
    cloud_scheduler = {
      name                  = "workflow-job-with-args"
      cron                  = "*/3 * * * *"
      time_zone             = "America/New_York"
      deadline              = "320s"
      service_account_email = data.google_compute_default_service_account.default.email
      argument              = jsonencode({ "searchTerm" : "Monday" })
    }
  }
  workflow_source = <<-EOF
  main:
      params: [input]
      steps:
      - checkSearchTermInInput:
          assign:
          - searchTerm: $${input.searchTerm}
      - readWikipedia:
          call: http.get
          args:
              url: https://en.wikipedia.org/w/api.php
              query:
                  action: opensearch
                  search: $${searchTerm}
          result: wikiResult
      - returnOutput:
              return: $${wikiResult.body[1]}
EOF

}
