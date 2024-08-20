resource "google_workflows_workflow" "example" {
  project         = var.project_id
  name            = var.workflow_name
  region          = var.region
  description     = var.description
  service_account = var.service_account_id
  call_log_level  = var.workflow_call_log_level
  labels          = var.workflow_labels
  user_env_vars   = var.workflow_user_env_vars
  source_contents = var.workflow_source
}