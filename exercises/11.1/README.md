#### Exercício 11.1 — Instalar o Argo CD e sincronizar a primeira Application (fixação guiada) · 40 min

**Objetivo:** instalar o Argo CD no minikube e colocar a `store-api` sob gestão GitOps com sync automático.

**Enunciado:** suba o minikube com Kubernetes 1.33, instale o Argo CD v2.13.x no namespace `argocd`, recupere a senha inicial, troque-a e delete o `argocd-initial-admin-secret`. Crie no GitHub um repositório público `fiap-store-config` com `base/` (Deployment + Service da `store-api`, com o `securityContext` completo do capítulo 10) e `overlays/dev/` (namespace `store-dev`, 2 réplicas, tag `1.0`). Valide localmente com `kubectl kustomize overlays/dev` **antes** de commitar. Crie a `Application` `fiap-store-dev` com `syncPolicy.automated` (`prune: true`, `selfHeal: true`), `syncOptions: [CreateNamespace=true]` e o finalizer `resources-finalizer.argocd.argoproj.io`. Por fim, faça um commit alterando as réplicas de 2 para 4 e **não execute nenhum comando no cluster** — apenas aguarde e comprove a reconciliação.

**Entregável:** link do repositório; `argocd app get fiap-store-dev` mostrando `Synced/Healthy`; `kubectl get pods -n store-dev -o wide` antes e depois do commit; print do grafo de recursos na UI do Argo; e o horário do commit comparado ao horário de criação dos Pods novos (`kubectl get pods -n store-dev --sort-by=.metadata.creationTimestamp`).

**Critério de aceite:** a Application em `Sync Status: Synced` e `Health Status: Healthy`; 4 Pods em `Running` **sem** nenhum `kubectl apply`/`scale` executado por você após a criação da Application; e `argocd app history fiap-store-dev` listando ao menos 2 revisões distintas.

<details><summary>Dica</summary>
Se a Application ficar `Unknown`, o problema é quase sempre o `repoURL` (use a URL `.git` completa) ou o `path` (relativo à raiz do repositório, sem barra inicial). Para não esperar os 3 minutos do polling, use `argocd app get fiap-store-dev --refresh`.
</details>

---
