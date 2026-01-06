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

package schedule_workflow

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestScheduleWorkflowAutoCreateSa(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t)

	bpt.DefineVerify(func(assert *assert.Assertions) {
		waitSeconds := 5
		bpt.DefaultVerify(assert)

		projectId := bpt.GetStringOutput("project_id")
		workflowId := bpt.GetStringOutput("workflow_id")
		workflowRegion := bpt.GetStringOutput("workflow_region")
		workflowRevisionId := bpt.GetStringOutput("workflow_revision_id")
		schedulerJobId := bpt.GetStringOutput("scheduler_job_id")
		gcOps := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", workflowRegion, "--format", "json"})

		workflowInfo := gcloud.Run(t, "workflows describe "+workflowId, gcOps)
		assert.Equal(workflowRevisionId, workflowInfo.Get("revisionId").String(), "should have the right Workflow RevisionId")

		schedulerInfo := gcloud.Run(t, "scheduler jobs describe "+schedulerJobId, gcOps)
		assert.Contains(schedulerInfo.Get("httpTarget").Get("uri").String(), workflowId, "should have the right Workflow ID")

		fmt.Println("Sleeping for ", waitSeconds, " seconds")
		time.Sleep(5 * time.Second)

		schedulerTrigger := gcloud.Run(t, "scheduler jobs run "+schedulerJobId, gcOps)
		assert.Equal("ENABLED", schedulerTrigger.Get("state").String(), "Scheduler Job should be in ENABLED status")

		fmt.Println("Sleeping for 60 seconds")
		time.Sleep(60 * time.Second)

		workflowExecution := gcloud.Run(t, "workflows executions list "+workflowId, gcOps).Array()[0]
		assert.Equal("SUCCEEDED", workflowExecution.Get("state").String(), "Workflow Job should be in SUCCEEDED status")
	})

	bpt.Test()
}
