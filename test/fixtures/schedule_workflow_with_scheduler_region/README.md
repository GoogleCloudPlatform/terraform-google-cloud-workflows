# Simple Example

This example illustrates how to use the `cloud-workflow` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The ID of the project in which to provision resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | Google Cloud project in which the service was created |
| scheduler\_job\_id | Google Cloud scheduler job id |
| scheduler\_region | Google Cloud scheduler region |
| workflow\_id | The id  of the workflow. |
| workflow\_region | The region of the workflow. |
| workflow\_revision\_id | The revision id of the workflow. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
