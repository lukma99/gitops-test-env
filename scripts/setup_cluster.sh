#!/usr/bin/env bash

# https://hub.docker.com/r/rancher/k3s/tags?page=1
K3S_VERSION=v1.26.1-k3s1
# https://artifacthub.io/packages/helm/argo/argo-cd
ARGO_HELM_CHART_VERSION=5.24.3
# https://artifacthub.io/packages/helm/argo/argocd-image-updater
ARGO_IMAGE_UPDATER_HELM_CHART_VERSION=0.8.4


if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl binary not found. Please install it first."
  exit 1
fi
if ! command -v helm >/dev/null 2>&1; then
  echo "helm binary not found. Please install it first."
  exit 1
fi
if ! command -v k3d >/dev/null 2>&1; then
  echo "k3d binary not found. Please install it first."
  exit 1
fi



if ! k3d cluster get release-promotion-cluster >/dev/null 2>&1; then
  echo "Creating cluster release-promotion-cluster"
  k3d cluster create release-promotion-cluster \
    --image rancher/k3s:${K3S_VERSION} \
    --k3s-arg "--disable=traefik@server:*" \
    --k3s-arg "--service-node-port-range=8010-65535@servers:*" \
    -p "9000-9050:9000-9050@server:*"

  sleep 3
else
  echo "Cluster release-promotion-cluster already exists, skipping creation"
fi

kubectl config set-context k3d-release-promotion-cluster

# check if current context switched correctly to the new one, to prevent installation of Argo CD
# in different clusters, when something went wrong
if [[ $(kubectl config current-context) != "k3d-release-promotion-cluster" ]]; then
  echo "Something went wrong. The current k8s context is not k3d-release-promotion-cluster"
  exit 1
fi

echo "Creating namespaces"
kubectl create namespace staging
kubectl create namespace qa
kubectl create namespace prod
kubectl create namespace argocd

echo
echo -n "Enter your GitHub Username or press Enter to skip this step: "
read -r GH_USER_NAME
echo -n "Enter your GitHub Token or press Enter to skip this step: "
read -r -s GH_TOKEN
echo
if [[ $GH_TOKEN != "" && $GH_USER_NAME != "" ]]; then
  kubectl delete secret github-repo-creds --namespace argocd
  kubectl create secret generic github-repo-creds --namespace argocd \
    --from-literal=type="git" \
    --from-literal=url="https://github.com/lukma99/gitops-test-env" \
    --from-literal=username="$GH_USER_NAME" \
    --from-literal=password="$GH_TOKEN"
  kubectl label secret github-repo-creds -n argocd argocd.argoproj.io/secret-type=repository
else
  echo "Skipping creation of GitHub connection and secrets."
fi


echo "Installing Argo CD"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
helm upgrade --install \
  --namespace argocd \
  --version ${ARGO_HELM_CHART_VERSION} \
  --set configs.params."server\.disable\.auth"=true \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=9000 \
  --set server.service.nodePortHttps=9001 \
  argo-cd argo/argo-cd


helm upgrade --install \
  --namespace argocd \
  --version ${ARGO_IMAGE_UPDATER_HELM_CHART_VERSION} \
  argocd-image-updater argo/argocd-image-updater
  #--set config.argocd.serverAddress=argo-cd-argocd-server.argocd.svc.cluster.local \
  #--set config.argocd.insecure=true \

kubectl apply -f ./argocd/control-app.yaml

echo ""
echo ""
echo "------------------------------------------------"
echo "FINISHED"
echo "Access Argo CD Web UI under http://localhost:9000"
echo "Auth is disabled, so you can start right away."
echo "------------------------------------------------"
