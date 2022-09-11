# terraform-google-cloud-workflow

This module is used to create a [Workflow](https://cloud.google.com/workflows/docs) and trigger can be set on it either using a Cloud Scheduler or a Event Arc Trigger

The resources/services/activations/deletions that this module will create/trigger are:

- Creates a Workflow
- Creates either a Cloud Scheduler OR  Event Arc Trigger

## Usage

* Usage of this module for scheduling a Workflows using a Cloud Scheduler:

```hcl
module "cloud_workflow" {
  source  = "terraform-google-modules/cloud-workflow/google"
  version = "~> 0.1"

  workflow_name         = "wf-sample"
  region                = "us-central1"
  service_account_email = "<svc_account>"
  workflow_trigger = {
    cloud_scheduler = {
      name                  = "workflow-job"
      cron                  = "*/3 * * * *"
      time_zone             = "America/New_York"
      deadline              = "320s"
      service_account_email = "<svc_account>"
    }
  }
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

* Usage of this module to trigger Workflow using Event Arc Trigger:

```hcl
module "cloud_workflow" {
  source  = "terraform-google-modules/cloud-workflow/google"
  version = "~> 0.1"

  workflow_name         = "wf-sample"
  region                = "us-central1"
  service_account_email = "<svc_account>"
  workflow_trigger = {
    event_arc = {
      name                  = "trigger-pubsub-workflow-tf"
      service_account_email = "<svc_account>"
      matching_criteria = [{
        attribute = "type"
        value     = "google.cloud.pubsub.topic.v1.messagePublished"
      }]
    }
  }
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
| project\_id | The project ID to deploy to | `string` | n/a | yes |
| region | The name of the region where workflow will be created | `string` | n/a | yes |
| service\_account\_create | Auto-create service account. | `bool` | `false` | no |
| service\_account\_email | Service account email. Unused if service account is auto-created. | `string` | `null` | no |
| workflow\_description | Description for the cloud workflow | `string` | `"Sample workflow Description"` | no |
| workflow\_labels | A set of key/value label pairs to assign to the workflow | `map(string)` | `{}` | no |
| workflow\_name | The name of the cloud workflow to create | `string` | n/a | yes |
| workflow\_source | Workflow YAML code to be executed. The size limit is 32KB. | `string` | n/a | yes |
| workflow\_trigger | Trigger for the Workflow . Cloud Scheduler OR Event Arc | <pre>object({<br>    cloud_scheduler = optional(object({<br>      name                  = string<br>      cron                  = string<br>      time_zone             = string<br>      deadline              = string<br>      argument              = optional(map(any))<br>      service_account_email = string<br>    }))<br>    event_arc = optional(object({<br>      name                  = string<br>      service_account_email = string<br>      matching_criteria = set(object({<br>        attribute = string<br>        operator  = optional(string)<br>        value     = string<br>      }))<br>    }))<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| event\_arc\_id | Google Event Arc id |
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
