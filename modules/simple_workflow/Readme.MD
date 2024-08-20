# terraform-google-cloud-workflow
This module is used to create a [Workflow](https://cloud.google.com/workflows/docs) without any triggers.

- Creates a Workflow

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The ID of the project | `string` | n/a | yes |
| region | The region where the workflow will be deployed | `string` | n/a | yes |
| service\_account\_id | The ID of the service account to associate with the workflow | `string` | n/a | yes |
| workflow\_name | The name of the workflow | `string` | n/a | yes |
| description | The description of the workflow | `string` | `"A simple workflow"` | no |
| workflow\_call\_log\_level | The log level for workflow calls | `string` | `"LOG_ERRORS_ONLY"` | no |
| workflow\_labels | Labels to apply to the workflow | `map(string)` | `{}` | no |
| workflow\_user\_env\_vars | User-defined environment variables for the workflow | `map(string)` | `{}` | no |
| workflow\_source | The source code of the workflow | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| workflow\_id | Workflow identifier for the resource with format projects/{{project}}/locations/{{region}}/workflows/{{name}} |


## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v1.3
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v5.7

