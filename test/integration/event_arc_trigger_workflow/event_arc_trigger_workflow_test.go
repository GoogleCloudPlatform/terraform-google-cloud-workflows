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

package event_arc_trigger_workflow

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestEventArcTriggerWorkflow(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		waitSeconds := 5
		bpt.DefaultVerify(assert)

		projectId := bpt.GetStringOutput("project_id")
		workflowId := bpt.GetStringOutput("workflow_id")
		workflowRegion := bpt.GetStringOutput("workflow_region")
		workflowRevisionId := bpt.GetStringOutput("workflow_revision_id")
		eventArcId := bpt.GetStringOutput("event_arc_id")
		gcOps := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", workflowRegion, "--format", "json"})
		gcOpsNoLoc := gcloud.WithCommonArgs([]string{"--project", projectId, "--format", "json"})

		op1 := gcloud.Run(t, "workflows list", gcOps).Array()[0]
		assert.Equal(workflowId, op1.Get("name").String(), "should have the right Workflow ID")
		assert.Equal(workflowRevisionId, op1.Get("revisionId").String(), "should have the right Workflow RevisionId")

		op2 := gcloud.Run(t, "eventarc triggers describe "+eventArcId, gcOps)
		pubsubTopicId := op2.Get("transport").Get("pubsub").Get("topic").String()
		// assert.Contains(op2.Get("transport").Get("pubsub").String(), workflowId, "should have the right Workflow ID")

		gcloud.Run(t, "pubsub topics publish "+pubsubTopicId+" --message \"TestPubsubMessage\"", gcOpsNoLoc)
		// assert.Equal("ENABLED", op3.Get("state").String(), "Scheduler Job should be in ENABLED status")

		fmt.Println("Sleeping for ", waitSeconds, " seconds")
		time.Sleep(5 * time.Second)

		op4 := gcloud.Run(t, "workflows  executions list "+workflowId, gcOps).Array()[0]
		assert.Equal("SUCCEEDED", op4.Get("state").String(), "Workflow Job should be in SUCCEEDED status")
		assert.Contains("TestPubsubMessage", op4.Get("result").String(), "Workflow Job should be in SUCCEEDED status")
	})

	bpt.Test()
}
