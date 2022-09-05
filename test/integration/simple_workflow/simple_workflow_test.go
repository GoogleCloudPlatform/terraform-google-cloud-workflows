package simple_workflow

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestSimpleWorkflowInspec(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		bpt.DefaultVerify(assert)

		projectId := bpt.GetStringOutput("project_id")
		workflowId := bpt.GetStringOutput("workflow_id")
		workflowRegion := bpt.GetStringOutput("workflow_region")
		workflowRevisionId := bpt.GetStringOutput("workflow_revision_id")
		gcOps := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", workflowRegion, "--format", "json"})

		op := gcloud.Run(t, "workflows list", gcOps).Array()[0]
		assert.Equal(workflowId, op.Get("name").String(), "should have the right Workflow ID")
		assert.Equal(workflowRevisionId, op.Get("revisionId").String(), "should have the right Workflow RevisionId")
	})

	bpt.Test()
}
