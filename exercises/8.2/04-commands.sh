#!/usr/bin/env bash
# roda os dois cenarios (12 min cada) e o teste do Secret; saida em run.log
set -euo pipefail
NS="-n store-dev"
CJ=cronjob/sincroniza-catalogo

amostra() {
  echo "### $(date +%T) ativos=$(kubectl $NS get $CJ -o jsonpath='{.status.active[*].name}' | wc -w)"
  kubectl $NS get cronjob,jobs,pods
}

kubectl apply -f 01-catalogo-secret.yaml
kubectl apply -f 02-sincroniza-cronjob-allow.yaml

# cenario Allow: 12 min, amostra a cada 30s; teste do Secret na primeira execucao
fim=$((SECONDS + 720)); secret_ok=0
while ((SECONDS < fim)); do
  amostra
  pod=$(kubectl $NS get pods -l batch.kubernetes.io/job-name --field-selector=status.phase=Running -o name | head -1)
  if ((secret_ok == 0)) && [[ -n $pod ]]; then
    echo "### secret antes ($pod)"
    kubectl $NS exec $pod -- printenv API_TOKEN
    kubectl $NS exec $pod -- cat /etc/catalogo/token
    kubectl $NS patch secret catalogo-secret -p '{"stringData":{"API_TOKEN":"token-v2"}}'
    sleep 75
    echo "### secret depois ($pod)"
    kubectl $NS exec $pod -- printenv API_TOKEN
    kubectl $NS exec $pod -- cat /etc/catalogo/token
    secret_ok=1
  fi
  sleep 30
done

# cenario Forbid: 12 min
kubectl apply -f 03-sincroniza-cronjob-forbid.yaml
fim=$((SECONDS + 720))
while ((SECONDS < fim)); do amostra; sleep 30; done

kubectl $NS describe $CJ
kubectl $NS get events --field-selector involvedObject.name=sincroniza-catalogo
