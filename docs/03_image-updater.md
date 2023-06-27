# 03: Image Updater

This instruction tells you, how to release a new version of the test application in all three stages
with Image-Updater.


### Building and Pushing a new docker image
* Go to the `Actions` tab in your GitHub Repository and run the `Build and Push Docker Image` Action
  * Enter a Docker Tag, which is newer than the previous version

### Promoting application
* Image Updater checks ghcr every XX seconds for new image tags. If there are newer tags, which mach the
  prerequisites from the annotations of the Argo CD application, it will automatically bump the version and
  commit the change into `.argocd-source-image-updater-STAGE.yaml`.
* This is picked up by Argo CD itself and it rolls out the new version.
* If you want specific stages not to use every new image tag, you can customize the annotations of the Argo CD
  application. See [Argo CD Image Updater Docs](https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/)
  for more information about the possibilities.
