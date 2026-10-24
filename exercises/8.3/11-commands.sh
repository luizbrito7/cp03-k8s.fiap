#!/usr/bin/env bash
set -uo pipefail # sem -e: varios passos falham de proposito
N="-n store-debug"
cliente() {
  kubectl $N run cliente --rm -i --quiet --image=curlimages/curl:8.10.1 --restart=Never -- \
    sh -c 'sleep 2; curl -sS -m 5 http://store-api/ready 2>&1; echo " exit=$?"'
}
ES='{range .items[*].endpoints[*]}{.addresses[0]} ready={.conditions.ready}{"\n"}{end}'

kubectl apply -f 01-namespace.yaml

# A: Job estourado
kubectl apply -f 02-job-relatorio-quebrado.yaml
kubectl $N wait --for=condition=failed job/relatorio-quebrado --timeout=180s
kubectl $N get job,pods
kubectl $N describe job relatorio-quebrado
kubectl $N logs -l job-name=relatorio-quebrado --prefix
kubectl apply -f 03-job-relatorio-corrigido.yaml
kubectl $N wait --for=condition=complete job/relatorio-corrigido --timeout=120s
kubectl $N logs job/relatorio-corrigido

# B: Secret invalido e Secret com \n
kubectl apply -f 04-secret-invalido.yaml
kubectl apply -f 05-secret-com-quebra.yaml -f 07-pod-senha.yaml
kubectl $N wait --for=jsonpath='{.status.phase}'=Succeeded pod/le-senha --timeout=60s
kubectl $N logs le-senha
kubectl $N delete pod le-senha
kubectl apply -f 06-secret-corrigido.yaml -f 07-pod-senha.yaml
kubectl $N wait --for=jsonpath='{.status.phase}'=Succeeded pod/le-senha --timeout=60s
kubectl $N logs le-senha

# C1: selector errado
kubectl apply -f 08-store-api-selector-errado.yaml
kubectl $N rollout status deploy/store-api
kubectl $N get endpointslices -l kubernetes.io/service-name=store-api -o wide
cliente
kubectl apply -f 09-store-api-corrigido.yaml
kubectl $N get endpointslices -l kubernetes.io/service-name=store-api -o wide
cliente

# C2: readinessProbe quebrada (recriado do zero, ver DEPURACAO)
kubectl $N delete deploy store-api
kubectl apply -f 10-store-api-probe-errada.yaml
sleep 30
kubectl $N get pods -l app=store-api -o wide
kubectl $N get endpointslices -l kubernetes.io/service-name=store-api -o jsonpath="$ES"
kubectl $N describe svc store-api
kubectl $N describe pod -l app=store-api
cliente
kubectl apply -f 09-store-api-corrigido.yaml
kubectl $N rollout status deploy/store-api
kubectl $N get endpointslices -l kubernetes.io/service-name=store-api -o jsonpath="$ES"
cliente
