#!/usr/bin/env bash
# para cada etapa: sobe a versao "-a", dispara carga e troca para "-b" no meio
set -euo pipefail
NS="-n store-dev"
OUT=${OUT:-.} # onde gravar os resultados da carga
kubectl apply -f 08-pod-carga.yaml
kubectl $NS wait --for=condition=Ready pod/carga --timeout=60s
kubectl $NS cp 07-carga.sh carga:/carga.sh

for f in ${@:-01-quebrado 02-etapa-a 03-etapa-b 04-etapa-c 05-etapa-d 06-final}; do
  echo "########## $f $(date +%T)"
  kubectl apply -f $f.yaml
  kubectl $NS rollout status deploy/store-api --timeout=180s
  sleep 15 # Pods antigos da etapa anterior terminam antes de medir
  img=$(kubectl $NS get deploy store-api -o jsonpath='{.spec.template.spec.containers[0].image}')
  novo=${img%-a}-b
  res=$OUT/carga-$f-$(date +%H%M%S).txt
  kubectl $NS exec carga -- sh /carga.sh 600 > $res &
  carga=$!
  sleep 5
  echo "set image $img -> $novo ($(date +%T))"
  kubectl $NS set image deploy/store-api store-api=$novo
  if [[ $f == 03-etapa-b || $f == 06-final ]]; then
    sleep 4
    t=$(kubectl $NS get pods -l app=store-api -o jsonpath='{range .items[?(@.metadata.deletionTimestamp)]}{.metadata.name}{"\n"}{end}' | head -1)
    echo "--- describe $t"
    kubectl $NS describe pod $t
    kubectl $NS get pod $t -o jsonpath='{.spec.containers[0].lifecycle}{"\n"}{.metadata.deletionTimestamp}{"\n"}'
  fi
  kubectl $NS rollout status deploy/store-api --timeout=180s
  wait $carga
  echo "--- resultado $f"
  cat $res
  kubectl $NS logs -l app=store-api --tail=3 --prefix 2>/dev/null | grep -i lifespan || true
  # volta para a tag -a na proxima etapa
done
