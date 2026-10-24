#!/usr/bin/env bash
# Gera a matriz de permissoes a partir de "kubectl auth can-i" reais.
# Uso: ./02-testa-rbac.sh > 03-matriz-gerada.md
set -euo pipefail

perfis="dev qa sre auditor"
namespaces="store-dev store-prod"
# recursos sem namespace: testados sem -n (com -n o can-i responde sobre
# o proprio objeto Namespace e da "yes" falso para list namespaces via view)
cluster_scoped="nodes namespaces storageclasses.storage.k8s.io clusterrolebindings.rbac.authorization.k8s.io"
# "verbo recurso [subresource]"
checks=(
  "get pods"
  "create pods"
  "get pods log"
  "create pods exec"
  "patch services"
  "get configmaps"
  "create deployments.apps"
  "delete deployments.apps"
  "create jobs.batch"
  "delete jobs.batch"
  "create horizontalpodautoscalers.autoscaling"
  "get secrets"
  "list secrets"
  "create secrets"
  "create persistentvolumeclaims"
  "create statefulsets.apps"
  "create daemonsets.apps"
  "list roles.rbac.authorization.k8s.io"
  "list rolebindings.rbac.authorization.k8s.io"
  "create rolebindings.rbac.authorization.k8s.io"
  "get nodes"
  "list namespaces"
  "list storageclasses.storage.k8s.io"
  "create clusterrolebindings.rbac.authorization.k8s.io"
)

printf '| verbo recurso |'
for g in $perfis; do for ns in $namespaces; do printf ' %s<br>%s |' "$g" "${ns#store-}"; done; done
printf '\n|---|'
for g in $perfis; do for ns in $namespaces; do printf '%s' '---|'; done; done
printf '\n'

for c in "${checks[@]}"; do
  read -r verbo recurso sub <<<"$c"
  printf '| `%s %s%s` |' "$verbo" "$recurso" "${sub:+/$sub}"
  for g in $perfis; do
    for ns in $namespaces; do
      escopo=(-n "$ns")
      [[ " $cluster_scoped " == *" $recurso "* ]] && escopo=()
      r=$(kubectl auth can-i "$verbo" "$recurso" ${sub:+--subresource=$sub} "${escopo[@]}" \
            --as="usuario.$g" --as-group="fiap:$g" 2>/dev/null || true)
      printf ' %s |' "$r"
    done
  done
  printf '\n'
done
