#!/usr/bin/env bash
# ciclo zero -> N -> zero com amostras a cada 5s
set -euo pipefail
NS="-n store-dev"
amostra() {
  echo "### $(date +%T) fila=$(kubectl $NS exec deploy/redis -- redis-cli LLEN pedidos)"
  kubectl $NS get pods -l app=store-worker
}

kubectl apply -f 01-redis.yaml
kubectl $NS rollout status deploy/redis
kubectl apply -f 02-keda-scaledjob.yaml
sleep 20
amostra # (a) fila vazia: nenhum Pod

kubectl $NS exec deploy/redis -- sh -c 'for i in $(seq 1 50); do redis-cli RPUSH pedidos "pedido-$i" >/dev/null; done'
inicio=$(date +%s)
# (b) pico e (c) volta a zero
while :; do
  amostra
  n=$(kubectl $NS get pods -l app=store-worker --no-headers 2>/dev/null | grep -cv Completed || true)
  fila=$(kubectl $NS exec deploy/redis -- redis-cli LLEN pedidos)
  (( $(date +%s) - inicio > 30 && n == 0 && fila == 0 )) && break
  sleep 5
done
kubectl $NS get jobs # successfulJobsHistoryLimit: 0, Jobs concluidos somem
kubectl $NS describe scaledjob store-worker-fila
