#!/usr/bin/env bash
set -uo pipefail # sem -e: os "no" e o 403 sao esperados
AS=system:serviceaccount:store-dev:monitor-sa
kubectl apply -f 01-monitor-rbac.yaml

# (a) can-i com impersonation
for c in "get pods" "list services" "watch endpoints" "get configmaps" "get secrets" "create pods" "delete pods"; do
  printf '%-18s %s\n' "$c" "$(kubectl auth can-i $c -n store-dev --as=$AS)"
done
kubectl auth can-i get pods --subresource=log -n store-dev --as=$AS
kubectl auth can-i list pods -n default --as=$AS
kubectl auth can-i --list -n store-dev --as=$AS

# (b) token de 1h e payload JWT
kubectl create token monitor-sa -n store-dev --duration=1h | cut -d. -f2 | tr '_-' '/+' | base64 -d

# (c) chamadas a API de dentro de um Pod com a SA
kubectl apply -f 02-pod-monitor.yaml
kubectl -n store-dev wait --for=condition=Ready pod/monitor
kubectl -n store-dev exec monitor -- sh -c '
SA=/var/run/secrets/kubernetes.io/serviceaccount
curl -sS --cacert $SA/ca.crt -H "Authorization: Bearer $(cat $SA/token)" -w "\nHTTP %{http_code}\n" https://kubernetes.default.svc/api/v1/namespaces/store-dev/pods
curl -sS --cacert $SA/ca.crt -H "Authorization: Bearer $(cat $SA/token)" -w "\nHTTP %{http_code}\n" https://kubernetes.default.svc/api/v1/namespaces/store-dev/secrets'
