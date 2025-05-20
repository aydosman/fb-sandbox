#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Cleaning up... Deleting Kind cluster fb-test"; kind delete cluster --name fb-test' EXIT

echo "Creating Kind Cluster..." 
if ! kind create cluster --config=kind.yaml > /dev/null 2>&1; then
  echo "Failed to create Kind cluster" >&2
  exit 1
fi

echo "Annotating control plane pods to exclude them from Fluent Bit..."
kubectl -n kube-system get pods -o name | xargs -I {} kubectl -n kube-system annotate {} fluentbit.io/exclude="true" --overwrite

if ! helm repo list | grep -q '^fluent[[:space:]]'; then
  echo "Adding fluent repo..."
  helm repo add fluent https://fluent.github.io/helm-charts > /dev/null || { echo "Failed to add fluent repo" >&2; exit 1; }
fi

if ! helm repo list | grep -q '^ingress-nginx[[:space:]]'; then
  echo "Adding ingress-nginx repo..." 
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx > /dev/null || { echo "Failed to add ingress-nginx repo" >&2; exit 1; }
fi

echo "Updating Helm repositories..." 
helm repo update > /dev/null || { echo "Failed to update Helm repositories" >&2; exit 1; }

echo "Installing fluent-bit..." 
helm install fluent-bit fluent/fluent-bit --namespace logging --create-namespace -f fb.yaml > /dev/null || { echo "Failed to install fluent-bit" >&2; exit 1; }

echo "Installing ingress-nginx..."
helm install nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace -f nginx-values.yaml > /dev/null || { echo "Failed to install ingress-nginx" >&2; exit 1; }

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx --for=condition=Ready pod -l app.kubernetes.io/name=ingress-nginx --timeout=120s > /dev/null || { echo "Ingress controller failed to become ready" >&2; exit 1; }

kubectl apply -f demo-app.yaml
kubectl wait --namespace default --for=condition=Available deployment/demo --timeout=60s > /dev/null || { echo "Demo app failed to become available" >&2; exit 1; }

kubectl apply -f demo-ingress.yaml

echo "Waiting for ingress to serve the demo app..."
# shellcheck disable=SC2034
for i in {1..30}; do
  if curl -s http://localhost/ | grep -q "hello from ingress"; then
    echo "Ingress is responding"
    break
  fi
  sleep 2
done

kubectl get pods -n logging -l app.kubernetes.io/name=fluent-bit -o name
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -o name

kubectl logs -n logging -l app.kubernetes.io/name=fluent-bit -f
