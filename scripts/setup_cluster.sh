#!/usr/bin/env bash

# https://hub.docker.com/r/rancher/k3s/tags?page=1
K3S_VERSION=v1.27.2-k3s1
# https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
INGRESS_NGINX_HELM_CHART_VERSION=4.7.0
# https://artifacthub.io/packages/helm/argo/argo-cd
ARGO_HELM_CHART_VERSION=5.36.5
# https://artifacthub.io/packages/helm/argo/argocd-image-updater
ARGO_IMAGE_UPDATER_HELM_CHART_VERSION=0.9.1
# Port over which to access ingresses in k3d cluster
INGRESS_PORT=8080
# Name of the k3d-cluster
CLUSTER_NAME=release-promotion-cluster


# Check if necessary tools are installed
for TOOL in docker kubectl helm k3d
do
  if ! command -v $TOOL >/dev/null 2>&1; then
    echo "$TOOL binary not found. Please install it first."
    exit 1
  fi
done


echo -n "You will now be asked for GitHub Username and Token. These will be stored into a kubernetes secret in your cluster. The secret is used by the tools to access your repository."
echo
echo -n "Enter your GitHub Username: "
read -r GH_USER_NAME
echo -n "Enter your GitHub Token (input redacted): "
read -r -s GH_TOKEN
echo
echo


# Create local k3d cluster only if it does not exist yet
if ! k3d cluster get ${CLUSTER_NAME} >/dev/null 2>&1; then
  echo "Creating cluster ${CLUSTER_NAME}"
  # traefik is disabled because ingress-nginx will be installed in the next steps as ingress-controller
  k3d cluster create ${CLUSTER_NAME} \
    --image rancher/k3s:${K3S_VERSION} \
    --k3s-arg "--disable=traefik@server:*" \
    -p "${INGRESS_PORT}:80@loadbalancer"
  sleep 3
else
  echo "Cluster ${CLUSTER_NAME} already exists, skipping creation"
fi


# Set current kubernetes context explicitly to new context to ensure the following commands work on the new cluster
kubectl config set-context k3d-${CLUSTER_NAME}

# Check if current context switched correctly to the new one, to prevent installation of Argo CD
# in different clusters, when something went wrong
if [[ $(kubectl config current-context) != "k3d-${CLUSTER_NAME}" ]]; then
  echo "Something went wrong. The current k8s context is not k3d-${CLUSTER_NAME}"
  exit 1
fi


# Operations on the cluster can only start, when it is up and running. This takes a short while, thus needing a wait loop
echo "Waiting for cluster node to become ready..."
until kubectl get nodes.metrics.k8s.io >/dev/null 2>&1; do
  sleep 2
  echo "Waiting for cluster node to become ready..."
done
echo "Cluster node is ready."
echo


echo "Installing Ingress-Nginx..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update ingress-nginx
echo "Running Helm install..."
helm upgrade --install \
  --namespace kube-system \
  --version ${INGRESS_NGINX_HELM_CHART_VERSION} \
  ingress-nginx ingress-nginx/ingress-nginx >/dev/null 2>&1
echo "Finished running Helm install."
echo


echo "Creating namespaces..."
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
kubectl create namespace argocd
echo "Finished creating namespaces."
echo


# For faster debug reasons this step is skipped when nothing was typed in in the first step.
# This skip only works, if the cluster and thus the secret was already initially created.
if [[ $GH_TOKEN != "" && $GH_USER_NAME != "" ]]; then
  echo "Create GitHub connection and secret."
  kubectl delete secret github-repo-creds --namespace argocd >/dev/null 2>&1
  kubectl create secret generic github-repo-creds --namespace argocd \
    --from-literal=type="git" \
    --from-literal=url="https://github.com/lukma99/gitops-test-env" \
    --from-literal=username="$GH_USER_NAME" \
    --from-literal=password="$GH_TOKEN"
  # Label is needed for Argo CD so it notices the secret is intended for repositories.
  kubectl label secret github-repo-creds -n argocd argocd.argoproj.io/secret-type=repository >/dev/null 2>&1
else
  echo "Skipping creation of GitHub connection and secret, because username/token not provided."
fi
echo


echo "Installing Argo CD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
echo "Running Helm install..."
helm upgrade --install \
  --namespace argocd \
  --version ${ARGO_HELM_CHART_VERSION} \
  --set configs.params."server\.disable\.auth"=true \
  --set configs.params."server\.insecure"=true \
  --set configs.params."server\.rootpath"=/argocd/ \
  argo-cd argo/argo-cd >/dev/null 2>&1
sleep 3
echo "Finished running Helm install."
echo


echo "Installing Argo CD Image Updater..."
echo "Running Helm install..."
helm upgrade --install \
  --namespace argocd \
  --version ${ARGO_IMAGE_UPDATER_HELM_CHART_VERSION} \
  argocd-image-updater argo/argocd-image-updater >/dev/null 2>&1
echo "Finished running Helm install."
echo


echo "Waiting for Ingress-Nginx to be ready before applying Argo CD Ingress..."
kubectl wait pods -n kube-system -l app.kubernetes.io/name=ingress-nginx --for condition=Ready --timeout=90s
echo "Waiting for Argo CD to be ready before applying Argo CD Ingress..."
kubectl wait pods -n argocd -l app.kubernetes.io/name=argocd-server --for condition=Ready --timeout=90s
echo


echo "Applying Argo CD Ingress and initial control-app Application"
kubectl apply -f ./scripts/ingress.yaml
kubectl apply -f ./argocd/control-app.yaml
echo "Finished applying Argo CD Ingress and initial control-app Application"


echo
echo
echo "------------------------------------------------"
echo "FINISHED"
echo "Access Argo CD Web UI under http://localhost:${INGRESS_PORT}/argocd"
echo "Auth is disabled, so you can start right away."
echo "Either wait a few minutes for control-app to reconcile or press 'Refresh' in the UI."
echo "------------------------------------------------"
