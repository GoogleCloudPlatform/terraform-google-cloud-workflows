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

module "cloud_workflow" {
  source = "../.."

  project_id              = var.project_id
  workflow_name           = "wf-sample-with-sa"
  region                  = "us-central1"
  service_account_create  = true
  call_log_level          = "CALL_LOG_LEVEL_UNSPECIFIED"
  execution_history_level = "EXECUTION_HISTORY_BASIC"
  user_env_vars = {
    key = "value1"
  }
  deletion_protection = false
  workflow_trigger = {
    cloud_scheduler = {
      name                  = "workflow-job-with-sa"
      cron                  = "*/3 * * * *"
      time_zone             = "America/New_York"
      deadline              = "320s"
      service_account_email = data.google_compute_default_service_account.default.email
    }
  }
  workflow_source = <<-EOF
  # This is a sample workflow, feel free to replace it with your source code
  #
  # This workflow does the following:
  # - reads current time and date information from an external API and stores
  #   the response in CurrentDateTime variable
  # - retrieves a list of Wikipedia articles related to the day of the week
  #   from CurrentDateTime
  # - returns the list of articles as an output of the workflow
  # FYI, In terraform you need to escape the $$ or it will cause errors.

  - getCurrentTime:
      call: http.get
      args:
          url: https://us-central1-workflowsample.cloudfunctions.net/datetime
      result: CurrentDateTime
  - readWikipedia:
      call: http.get
      args:
          url: https://en.wikipedia.org/w/api.php
          query:
              action: opensearch
              search: $${CurrentDateTime.body.dayOfTheWeek}
      result: WikiResult
  - returnOutput:
      return: $${WikiResult.body[1]}
EOF

}
