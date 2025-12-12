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
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func writeFile(fileName string) {
	d1 := []byte("hello")
	err := os.WriteFile(fileName, d1, 0644)
	check(err)
}

func uploadToGCS(bucket, file string) {
	cmd := exec.Command("gsutil", "cp", file, "gs://"+bucket+"/"+filepath.Base(file))
	err := cmd.Run()
	check(err)
}

// Retry if these errors are encountered.
var retryErrors = map[string]string{
	".*Provider produced inconsistent final plan.*": "Provider bug, retry",
}


func TestGcsEventArcTriggerWorkflow(t *testing.T) {
	bpt := tft.NewTFBlueprintTest(t, tft.WithRetryableTerraformErrors(retryErrors, 5, time.Minute))

	bpt.DefineVerify(func(assert *assert.Assertions) {
		waitSeconds := 5
		bpt.DefaultVerify(assert)

		fmt.Println("Sleeping for ", waitSeconds, " seconds")
		time.Sleep(5 * time.Second)

		projectId := bpt.GetStringOutput("project_id")
		workflowId := bpt.GetStringOutput("workflow_id")
		workflowRegion := bpt.GetStringOutput("workflow_region")
		workflowRevisionId := bpt.GetStringOutput("workflow_revision_id")
		gcsBucket := bpt.GetStringOutput("gcs_bucket")
		gcOps := gcloud.WithCommonArgs([]string{"--project", projectId, "--location", workflowRegion, "--format", "json"})

		workflowInfo := gcloud.Run(t, "workflows describe "+workflowId, gcOps)
		assert.Equal(workflowRevisionId, workflowInfo.Get("revisionId").String(), "should have the right Workflow RevisionId")

		sampleFile := "/tmp/random.txt"
		fmt.Println("Writing a sample file " + sampleFile)
		writeFile(sampleFile)
		fmt.Println("Uploading a sample file to GCS Bucket " + gcsBucket)
		uploadToGCS(gcsBucket, sampleFile)

		fmt.Println("Sleeping for ", waitSeconds, " seconds")
		time.Sleep(5 * time.Second)

		workflowExecution := gcloud.Run(t, "workflows  executions list "+workflowId, gcOps).Array()[0]
		assert.Equal("SUCCEEDED", workflowExecution.Get("state").String(), "Workflow Job should be in SUCCEEDED status")
		// assert.Contains(filepath.Base(sampleFile), workflowExecution.Get("result").String(), "Workflow Job result should contain object name")

		workflowExecutionId := workflowExecution.Get("name").String()
		workflowExecutionInfo := gcloud.Run(t, "workflows  executions describe --workflow="+workflowId+" "+workflowExecutionId, gcOps)
		assert.Contains(workflowExecutionInfo.Get("result").String(), filepath.Base(sampleFile), "Workflow Job result should contain object name")
	})

	bpt.Test()
}
