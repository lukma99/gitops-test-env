# 01: Manual

This instruction tells you, how to do the process from building a container image to deploying it in all three
stages manually without the help of pipelines or other third party applications (except Argo CD for GitOps).


### Building and Pushing a new docker image
```shell
REGISTRY_USER=YOURNAME
  REGISTRY_PASSWORD=YOURPASSWORD
IMAGE_NAME=gitops-test-env
IMAGE_TAG=X.Y.Z

echo $REGISTRY_PASSWORD | docker login ghcr.io -u $REGISTRY_USER --password-stdin

docker build \
--build-arg DOCKER_TAG=${IMAGE_TAG} \
--tag ghcr.io/${IMAGE_NAME}:${IMAGE_TAG} \
--tag ghcr.io/${IMAGE_NAME}:latest \
--label "org.opencontainers.image.source=https://github.com/${IMAGE_NAME}" \
./app

docker push --all-tags ghcr.io/${IMAGE_NAME}

```


### Promoting application
Do the following for each stage you are interested in updating (typically dev -> staging -> prod):
* Create new branch from main
* Bump the image tag to the new one in `./k8s-deployments/01-manual/overlays/STAGE/kustomization.yaml`
* Commit and push the new branch
* Go to GitHub and create a Pull Request
* If ready, merge the branch and wait for Argo CD to propagate the changes (or Sync in UI)