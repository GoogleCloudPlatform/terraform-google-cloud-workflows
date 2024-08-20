output "workflow_id" {
  value       = google_workflows_workflow.example.id
  description = "Workflow identifier for the resource with format projects/{{project}}/locations/{{region}}/workflows/{{name}}"
}