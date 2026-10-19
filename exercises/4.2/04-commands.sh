#!/usr/bin/env bash
set -euo pipefail
NS="-n store-dev"

# o control-plane do minikube e agendavel; no kind tiro o taint para ter 3 "zonas"
kubectl taint node fiap-store-control-plane node-role.kubernetes.io/control-plane:NoSchedule-
kubectl label node fiap-store-control-plane topology.kubernetes.io/zone=za
kubectl label node fiap-store-worker topology.kubernetes.io/zone=zb
kubectl label node fiap-store-worker2 topology.kubernetes.io/zone=zc

run() {
  kubectl $NS delete deploy store-api --ignore-not-found --wait
  kubectl $NS wait --for=delete pod -l app=store-api --timeout=120s || true
  kubectl apply -f "$1"
  kubectl $NS rollout status deploy/store-api --timeout=90s || true
  kubectl $NS get pods -o wide --sort-by=.spec.nodeName
  kubectl $NS scale deploy/store-api --replicas=10
  kubectl $NS rollout status deploy/store-api --timeout=60s || true
  kubectl $NS get pods -o wide --sort-by=.spec.nodeName
}

run 01-antiaffinity.yaml
run 02-topologyspread.yaml
run 03-required.yaml
kubectl $NS describe pod "$(kubectl $NS get pods --field-selector=status.phase=Pending -o name | head -1)"
