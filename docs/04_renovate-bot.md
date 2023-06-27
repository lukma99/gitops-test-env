# 04: Renovate Bot

This instruction tells you, how to release a new version of the test application in all three stages
with Renovate Bot.


### Building and Pushing a new docker image
* Go to the `Actions` tab in your GitHub Repository and run the `Build and Push Docker Image` Action
  * Enter a Docker Tag, which is newer than the previous version

### Promoting application
* Renovate bot works as an GitHub Action in this repository. It runs on schedule every 15 minutes, but is also
  triggered after the `Build and Push Docker Image` action, to shorten wait times
* Renovate bot is configured by the file `.github/renovate.js`. There it is specified, that only the kustomize files
  under `/k8s-deployments/04-dependency-bot` will be scanned for new image versions
* If a new version is available in ghcr, then renovate bot creates a PR (one for each stage)
* After you accept a PR, the new tag is present in the main branch, and Argo CD will therefore deploy the new version