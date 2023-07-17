# 02: CI-Pipeline

This instruction tells you, how to release a new version of the test application in all three stages
with the `Deployment Pipeline with PRs` GitHub Action.


### Building and Pushing a new docker image
* Go to the `Actions` tab in your GitHub Repository and run the `Build and Push Docker Image` Action
  * Enter a Docker Tag, which is newer than the previous version. You must use semver pattern ("X.Y.Z" e.g. 1.1.0).

### Promoting application
* The `Deployment Pipeline with PRs` GitHub Action runs automatically after `Build and Push Docker Image` finished
* When it is finished, three new PRs are created, which update the image tag of the according stage
* After you accept a PR, the new tag is present in the main branch, and Argo CD will therefore deploy the new version
* Delete the old branches for cleanup on the PR