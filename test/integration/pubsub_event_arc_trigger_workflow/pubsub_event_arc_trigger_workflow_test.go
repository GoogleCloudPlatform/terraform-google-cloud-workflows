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

func TestPubsubEventArcTriggerWorkflow(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		waitSeconds := 5
		bpt.DefaultVerify(assert)

		projectId := bpt.GetStringOutput("project_id")
		workflowId := bpt.GetStringOutput("workflow_id")
		workflowRegion := bpt.GetStringOutput("workflow_region")
		workflowRevisionId := bpt.GetStringOutput("workflow_revision_id")
		eventArcId := bpt.GetStringOutput("event_arc_id")
		pubsubTopicId := bpt.GetStringOutput("pubsub_topic_id")
		gcOps := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", workflowRegion, "--format", "json"})
		gcOpsNoLoc := gcloud.WithCommonArgs([]string{"--project", projectId, "--format", "json"})

		workflowInfo := gcloud.Run(t, "workflows describe "+workflowId, gcOps)
		assert.Equal(workflowRevisionId, workflowInfo.Get("revisionId").String(), "should have the right Workflow RevisionId")

		eventArcInfo := gcloud.Run(t, "eventarc triggers describe "+eventArcId, gcOps)
		// pubsubTopicId := eventArcInfo.Get("transport").Get("pubsub").Get("topic").String()
		assert.Equal(eventArcId, eventArcInfo.Get("name").String(), "should have the right Eventarc ID")

		pubSubTrigger := gcloud.Run(t, "pubsub topics publish "+pubsubTopicId+" --message \"TestPubsubMessage\"", gcOpsNoLoc)
		assert.Equal(1, len(pubSubTrigger.Get("messageIds").Array()), "Pubsub Published Messages Should be 1")

		fmt.Println("Sleeping for ", waitSeconds, " seconds")
		time.Sleep(5 * time.Second)

		workflowExecution := gcloud.Run(t, "workflows  executions list "+workflowId, gcOps).Array()[0]
		assert.Equal("SUCCEEDED", workflowExecution.Get("state").String(), "Workflow Job should be in SUCCEEDED status")

		workflowExecutionId := workflowExecution.Get("name").String()
		workflowExecutionInfo := gcloud.Run(t, "workflows  executions describe --workflow="+workflowId+" "+workflowExecutionId, gcOps)
		assert.Contains(workflowExecutionInfo.Get("result").String(), "TestPubsubMessage", "Workflow Job result should contain object name")
	})

	bpt.Test()
}
