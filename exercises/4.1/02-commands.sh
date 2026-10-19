#!/usr/bin/env bash
set -euo pipefail
NS="-n store-dev"
D=deployment/store-api

# revisao 1
kubectl apply -f 01-deployment.yaml
kubectl $NS rollout status $D
kubectl $NS annotate $D kubernetes.io/change-cause="rev1: store-api:1.0, 4 replicas" --overwrite

# (a) imagem 2.0, com kubectl get pods -w em outro terminal
kubectl $NS set image $D store-api=store-api:2.0
kubectl $NS annotate $D kubernetes.io/change-cause="rev2: imagem store-api:2.0" --overwrite
kubectl $NS rollout status $D

# (b) APP_ENV dev -> homolog
kubectl $NS set env $D APP_ENV=homolog
kubectl $NS annotate $D kubernetes.io/change-cause="rev3: APP_ENV=homolog" --overwrite
kubectl $NS rollout status $D

# (c) limits.memory 384Mi
kubectl $NS set resources $D -c store-api --limits=memory=384Mi
kubectl $NS annotate $D kubernetes.io/change-cause="rev4: limits.memory=384Mi" --overwrite
kubectl $NS rollout status $D

kubectl $NS get deploy store-api
kubectl $NS rollout history $D
kubectl $NS get rs -o wide

# prova: com limite 2 sobram 2 antigas + a atual = 3 revisoes
kubectl $NS patch $D -p '{"spec":{"revisionHistoryLimit":2}}'
kubectl $NS rollout history $D
kubectl $NS get rs -o wide
