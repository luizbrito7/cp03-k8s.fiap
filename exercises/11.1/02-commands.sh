#!/usr/bin/env bash
# 11.1 adaptado: kind (em vez de minikube), Argo CD v3.5.6, Gitea no cluster (em vez do GitHub)
set -euo pipefail

# Argo CD
kubectl create ns argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.6/manifests/install.yaml
kubectl -n argocd port-forward svc/argocd-server 8081:443 &

# senha inicial -> troca -> apaga o secret inicial
INIT=$(argocd admin initial-password -n argocd | head -1)
argocd login localhost:8081 --username admin --password "$INIT" --insecure --grpc-web
argocd account update-password --current-password "$INIT" --new-password "$NOVA_SENHA" --grpc-web
kubectl -n argocd delete secret argocd-initial-admin-secret

# Gitea (git server do lab), repo publico fiap-store-config
helm install gitea gitea-charts/gitea -n gitea --create-namespace --version 12.7.0 \
  --set postgresql-ha.enabled=false --set postgresql.enabled=false \
  --set valkey-cluster.enabled=false --set valkey.enabled=false \
  --set gitea.config.database.DB_TYPE=sqlite3 \
  --set gitea.admin.username=fiap --set gitea.admin.password="$GITEA_PASS"
kubectl -n gitea port-forward svc/gitea-http 3000:3000 &

# no repo de config: valida ANTES de commitar
kubectl kustomize overlays/dev

# Application
kubectl apply -f 01-application-dev.yaml
argocd app get fiap-store-dev --grpc-web
kubectl get pods -n store-dev -o wide

# commit 2 -> 4 replicas (no repo de config) e NENHUM comando de escrita no cluster depois disso
#   sed -i 's/count: 2/count: 4/' overlays/dev/kustomization.yaml && git commit -am ... && git push
kubectl get pods -n store-dev -o wide
kubectl get pods -n store-dev --sort-by=.metadata.creationTimestamp
argocd app history fiap-store-dev --grpc-web
