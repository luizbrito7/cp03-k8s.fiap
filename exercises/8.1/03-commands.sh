#!/usr/bin/env bash
set -euo pipefail
NS="-n store-dev"

# job paralelo: amostras de pods durante a execucao
kubectl apply -f 01-job-paralelo.yaml
for i in 1 2 3 4 5 6; do sleep 4; kubectl $NS get job,pods -l job-name=processa-pedidos; done
kubectl $NS wait --for=condition=complete job/processa-pedidos --timeout=120s
kubectl $NS get job processa-pedidos
kubectl logs -l job-name=processa-pedidos $NS --prefix --tail=1

# job indexed: cada pod recebe JOB_COMPLETION_INDEX
kubectl apply -f 02-job-indexed.yaml
kubectl $NS wait --for=condition=complete job/processa-particoes --timeout=120s
kubectl logs -l job-name=processa-particoes $NS --tail=1 | sort
