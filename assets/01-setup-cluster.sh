#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
export DOCKER_CONTEXT=rootless
export KUBECONFIG="$PWD/kubeconfig"

docker build -q -t store-api:1.0 ../app/store-api
docker build -q --build-arg APP_VERSION=2.0 -t store-api:2.0 ../app/store-api

kind get clusters | grep -qx fiap-store || kind create cluster --config 00-kind-cluster.yaml --kubeconfig kubeconfig
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.33.0/manifests/calico.yaml
kind load docker-image store-api:1.0 store-api:2.0 --name fiap-store
kubectl wait --for=condition=Ready node --all --timeout=300s
