/**
 * Copyright 2025 Google LLC
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

module "service_account" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.7.0"
  project_id    = var.project_id
  prefix        = "simple-workflow"
  names         = ["simple"]
  project_roles = ["${var.project_id}=>roles/workflows.invoker"]
}

module "standalone_workflow" {
  source  = "../../modules/simple_workflow"

  project_id            = var.project_id
  workflow_name         = "standalone-workflow"
  location              = "us-central1"
  service_account_email = module.service_account.email
  workflow_source       = <<-EOF
  # This is a sample workflow that simply reads wikipedia
  # Note that $$ is needed for Terraform

  main:
      steps:
      - readWikipedia:
          call: http.get
          args:
              url: https://en.wikipedia.org/w/api.php
              query:
                  action: opensearch
                  search: GoogleCloudPlatform
          result: wikiResult
      - returnOutput:
              return: $${wikiResult.body[1]}
EOF
}
