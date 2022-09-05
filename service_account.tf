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

locals {
  create_sa     = length(var.service_account_email) > 0 ? 0 : 1
  sa_account_id = local.create_sa == 0 ? "" : "tf-wf-${substr(var.workflow_name, 0, min(15, length(var.workflow_name)))}-${random_string.sa_suffix.result}"
  sa_email      = local.create_sa == 0 ? var.service_account_email : google_service_account.account[0].email
  roles         = toset(concat(var.service_account_roles, ["roles/logging.logWriter"]))
}

resource "random_string" "sa_suffix" {
  upper   = false
  lower   = true
  special = false
  length  = 4
}

resource "google_service_account" "account" {
  count        = local.create_sa
  account_id   = local.sa_account_id
  display_name = "Service Account for cloud workflow"
  project      = var.project_id
}

resource "google_project_iam_member" "account" {
  for_each = toset(local.roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${local.sa_email}"
}