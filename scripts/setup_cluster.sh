#!/usr/bin/env bash

# https://hub.docker.com/r/rancher/k3s/tags?page=1
K3S_VERSION=v1.26.1-k3s1
# https://artifacthub.io/packages/helm/argo/argo-cd
ARGO_HELM_CHART_VERSION=5.24.3

K3D_ARGS=(
  # Specify k3s (and therefore k8s) version
  "--image rancher/k3s:${K3S_VERSION}"
  # Allow ports less than 30000
 # '--k3s-arg= "--kube-apiserver-arg=service-node-port-range=8010-32767"'
  '--k3s-arg "--service-node-port-range=8010-65535@servers:*"'
  # Disable traefik
  '--k3s-arg "--disable=traefik@server:*"'
  # Disable servicelb (avoids "Pending" svclb pods and we use nodePorts right now anyway)
  # '--k3s-server-arg=--disable=servicelb'
  # maybe if ports not accessible
  # '--network=host'
)

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

echo "Creating cluster release-promotion-cluster"
k3d cluster create release-promotion-cluster \
  --image rancher/k3s:${K3S_VERSION} \
  --k3s-arg "--disable=traefik@server:*" \
  --k3s-arg "--service-node-port-range=8010-65535@servers:*" \
  -p "9000:9000@server:*" \
  -p "9001:9001@server:*" \
  -p "9002:9002@server:*" \
  -p "9003:9003@server:*" \
  -p "9004:9004@server:*" \

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

echo "Installing Argo CD"
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install \
  --namespace argocd \
  --version ${ARGO_HELM_CHART_VERSION} \
  --set configs.params."server\.disable\.auth"=true \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=9000 \
  --set server.service.nodePortHttps=9001 \
  argo-cd argo/argo-cd

kubectl apply -f ./argocd/control-app.yaml

echo ""
echo ""
echo "------------------------------------------------"
echo "FINISHED"
echo "Access Argo CD Web UI under http://localhost:9000"
echo "Auth is disabled, so you can start right away."
echo "------------------------------------------------"
