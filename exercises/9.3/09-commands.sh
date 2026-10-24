#!/usr/bin/env bash
set -uo pipefail # sem -e: os erros sao o objeto do exercicio
P=$(kubectl -n store-dev get pods -l batch.kubernetes.io/job-name -o name | head -1)

kubectl apply -f 01-cenario-a.yaml -f 02-cenario-b.yaml -f 03-cenario-c.yaml -f 04-cenario-d.yaml

# A: logs com Role so de pods
kubectl logs -n store-dev $P --as=user.a
kubectl auth can-i get pods --subresource=log -n store-dev --as=user.a

# B: deployments no apiGroup core
kubectl get deployments -n store-dev --as=user.b
kubectl auth can-i list deployments.apps -n store-dev --as=user.b

# C: apply com create/update; -v=6 mostra as requisicoes reais
kubectl apply -f 03-deploy.yaml --as=user.c -v=6

# D: RoleBinding de edit so em store-dev
kubectl get pods -n store-prod --as=user.d
kubectl auth can-i create deployments.apps -n store-prod --as=user.d

# correcoes minimas
kubectl apply -f 05-cenario-a-corrigido.yaml -f 06-cenario-b-corrigido.yaml -f 07-cenario-c-corrigido.yaml -f 08-cenario-d-corrigido.yaml

kubectl auth can-i get pods --subresource=log -n store-dev --as=user.a        # yes
kubectl auth can-i create pods --subresource=exec -n store-dev --as=user.a    # no (adjacente)
kubectl auth can-i list deployments.apps -n store-dev --as=user.b             # yes
kubectl auth can-i create deployments.apps -n store-dev --as=user.b           # no (adjacente)
kubectl apply -f 03-deploy.yaml --as=user.c -v=6                              # GET 404 + POST 201
sed 's/replicas: 1/replicas: 2/' 03-deploy.yaml | kubectl apply -f - --as=user.c -v=6   # GET 200 + PATCH 200
kubectl auth can-i delete deployments.apps -n store-prod --as=user.c          # no (adjacente)
kubectl auth can-i create deployments.apps -n store-prod --as=user.d          # yes
kubectl auth can-i create deployments.apps -n default --as=user.d             # no (adjacente)
kubectl auth can-i create rolebindings -n store-prod --as=user.d              # no (edit nao da RBAC)
