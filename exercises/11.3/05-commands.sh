#!/usr/bin/env bash
# 11.3: correcoes sempre pelo Git (repo fiap-store-config); no cluster so o drift proposital
set -uo pipefail
A=fiap-store-dev

# A. drift com selfHeal ligado
kubectl scale deploy/store-api -n store-dev --replicas=1
kubectl set image deploy/store-api store-api=nginx:1.27 -n store-dev
argocd app diff $A --grpc-web            # imediatamente, antes do self-heal
kubectl -n store-dev get deploy store-api -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}'
# A. drift com selfHeal desligado
argocd app set $A --sync-policy none --grpc-web
kubectl scale deploy/store-api -n store-dev --replicas=1
kubectl set image deploy/store-api store-api=nginx:1.27 -n store-dev
sleep 150; argocd app get $A --grpc-web
# A. correcao: Application declarativa de volta (automated + selfHeal)
kubectl apply -f ../11.2/02-application-dev.yaml

# B. (repo) commit progressDeadlineSeconds: 90 na base; commit newTag "9.9-inexistente" em overlays/dev
argocd app get $A --grpc-web             # Synced + Degraded
kubectl -n store-dev describe pod <pod em ImagePullBackOff>
# B. correcao (repo): git revert HEAD && git push

# C. (repo) commit base/store-relatorio.yaml com secretKeyRef store-db-credentials
kubectl -n store-dev describe pod -l app=store-relatorio   # CreateContainerConfigError
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.40.0/controller.yaml
for env in dev prod; do
  kubectl create secret generic store-db-credentials -n store-$env --from-literal=DB_PASSWORD="$SENHA" \
    --dry-run=client -o yaml | kubeseal --format yaml --controller-namespace kube-system \
    > overlays/$env/sealed-db-credentials.yaml
done
grep -ri "$SENHA" . --exclude-dir=.git   # vazio
# C. (repo) commit dos SealedSecrets; o controller cria o Secret
kubectl get secret store-db-credentials -n store-dev

# D. bonus
kubectl apply -f 01-appproject-sem-namespace.yaml -f 02-application-store-qa.yaml
argocd app get fiap-store-qa --grpc-web
kubectl -n argocd logs argocd-application-controller-0 --since=10m | grep fiap-store
