#!/usr/bin/env bash
set -uo pipefail # sem -e: as rejeicoes do PSA sao o objeto do exercicio

kubectl apply -f 01-namespaces.yaml
kubectl apply -f 02-store-api-restrito.yaml
kubectl -n store-seguro rollout status deploy/store-api
kubectl get ns store-seguro --show-labels

# privilegiado: rejeitado nos dois perfis
kubectl apply -f 03-pod-privilegiado.yaml -n store-seguro
kubectl apply -f 03-pod-privilegiado.yaml -n store-legado

kubectl get pods -n store-seguro -o wide
kubectl exec -n store-seguro deploy/store-api -- id
kubectl exec -n store-seguro deploy/store-api -- sh -c 'touch /app/x; touch /tmp/x && echo tmp-gravavel; grep Cap /proc/1/status'

# root comum: aceito no baseline, rejeitado no restricted
kubectl apply -f 04-pod-root-simples.yaml -n store-legado
kubectl apply -f 04-pod-root-simples.yaml -n store-seguro
kubectl -n store-legado exec pod-root-simples -- id
