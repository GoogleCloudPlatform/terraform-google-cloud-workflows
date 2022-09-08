# terraform-google-cloud-workflow

This module was generated from [terraform-google-module-template](https://github.com/terraform-google-modules/terraform-google-module-template/), which by default generates a module that simply creates a GCS bucket. As the module develops, this README should be updated.

The resources/services/activations/deletions that this module will create/trigger are:

- Create a GCS bucket with the provided name

## Usage

Basic usage of this module is as follows:

```hcl
module "cloud_workflow" {
  source  = "terraform-google-modules/cloud-workflow/google"
  version = "~> 0.1"

  workflow_name             = "wf-sample"
  region                    = "us-central1"
  service_account_email     = "<svc_acc>"
  cloud_scheduler_name      = "workflow-job"
  cloud_scheduler_cron      = "*/3 * * * *"
  cloud_scheduler_time_zone = "America/New_York"
  cloud_scheduler_deadline  = "320s"
  workflow_source       = <<-EOF
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
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_scheduler\_cron | Cron which represents the schedule on which the Cloud Scheduler Job will be executed. | `string` | n/a | yes |
| cloud\_scheduler\_deadline | Cloud Scheduler Time Zone. | `string` | n/a | yes |
| cloud\_scheduler\_name | Cloud Scheduler Name | `string` | n/a | yes |
| cloud\_scheduler\_time\_zone | Cloud Scheduler Time Zone. | `string` | n/a | yes |
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| region | The name of the region where workflow will be created | `string` | n/a | yes |
| service\_account\_email | Service Account email needed for the service | `string` | `""` | no |
| workflow\_description | Description for the cloud workflow | `string` | `"Sample workflow Description"` | no |
| workflow\_labels | A set of key/value label pairs to assign to the workflow | `map(string)` | `{}` | no |
| workflow\_name | The name of the cloud workflow to create | `string` | n/a | yes |
| workflow\_source | Workflow YAML code to be executed. The size limit is 32KB. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| scheduler\_job\_id | Google Cloud scheduler job id |
| workflow\_id | Workflow identifier for the resource with format projects/{{project}}/locations/{{region}}/workflows/{{name}} |
| workflow\_region | The region of the workflow. |
| workflow\_revision\_id | The revision of the workflow. A new one is generated if the service account or source contents is changed. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
