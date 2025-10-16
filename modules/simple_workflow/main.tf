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

locals {
  service_account_email = (
    var.service_account_create
    ? (
      length(module.service_account) > 0
      ? module.service_account[0].email
      : null
    )
    : var.service_account_email
  )
}

resource "random_string" "string" {
  count   = var.service_account_create ? 1 : 0
  length  = 6
  lower   = true
  upper   = false
  special = false
  numeric = false
}

module "service_account" {
  count         = var.service_account_create ? 1 : 0
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.1.1"
  project_id    = var.project_id
  prefix        = "wf-${random_string.string[0].result}"
  names         = ["simple"]
  project_roles = ["${var.project_id}=>roles/workflows.invoker"]
}

resource "google_workflows_workflow" "simple_workflow" {
  name            = var.workflow_name
  region          = var.region
  description     = var.workflow_description
  service_account = local.service_account_email
  project         = var.project_id
  labels          = var.workflow_labels
  source_contents = var.workflow_source
}
