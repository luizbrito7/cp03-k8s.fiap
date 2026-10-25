#### Exercício 11.3 — Depuração: Application `OutOfSync` e `Degraded` (análise) · 50 min

**Objetivo:** diagnosticar e corrigir os três modos de falha mais comuns em GitOps, distinguindo problema de sync de problema de aplicação.

**Enunciado:** você é o plantonista. Reproduza, diagnostique e corrija **três cenários**, documentando para cada um: sintoma observado, comando(s) usados no diagnóstico, causa raiz e correção — **sempre corrigindo pelo Git**, nunca pelo cluster.

**Cenário A — drift manual.** Com `selfHeal: true` ativo, execute `kubectl scale deploy/store-api -n store-dev --replicas=1` e depois `kubectl set image deploy/store-api store-api=nginx:1.27 -n store-dev`. Registre a saída de `argocd app diff` **antes** da reconciliação e comprove que o Argo desfez ambas as alterações. Em seguida, desligue o `selfHeal` (`argocd app set ... --sync-policy none`), repita o drift e explique a diferença de comportamento.

**Cenário B — `Synced` + `Degraded`.** Commite uma tag de imagem inexistente. Comprove que o Argo reporta `Synced` e `Degraded` simultaneamente e explique, em 5 linhas, por que essa combinação **não** é um bug do Argo. Corrija com `git revert`.

**Cenário C — sync falhando por dependência ausente.** Adicione ao `base/` um Deployment que consome `DB_PASSWORD` via `secretKeyRef` de um Secret `store-db-credentials` que **não** existe no cluster (e que corretamente não está no Git). Observe o Pod em `CreateContainerConfigError`. Resolva instalando o Sealed Secrets, gerando o `SealedSecret` com `kubeseal`, commitando-o e deixando o Argo criar o Secret real. Comprove que o arquivo commitado **não** contém a senha em texto legível.

**Cenário D (bônus) — falha por RBAC.** Crie um `AppProject` cujo `clusterResourceWhitelist` não inclua `Namespace` e tente sincronizar uma Application com `CreateNamespace=true`. Registre a mensagem de erro.

**Entregável:** um relatório em Markdown com uma seção por cenário (sintoma, diagnóstico, causa raiz, correção), incluindo as saídas de `argocd app get`, `argocd app diff`, `kubectl describe pod` e os logs relevantes do `argocd-application-controller`; mais o `SealedSecret` commitado e a saída de `kubectl get secret store-db-credentials -n store-dev`.

**Critério de aceite:** os três cenários principais reproduzidos e corrigidos, com a Application terminando em `Synced/Healthy` nos três; a explicação do cenário B identifica corretamente que sync compara Git x cluster e health avalia o funcionamento dos recursos; e o `SealedSecret` no repositório não revela a senha (comprove com `grep -i` na senha original retornando vazio).

<details><summary>Dica</summary>
`kubectl logs -n argocd deploy/argocd-application-controller --tail=100` é onde as falhas reais de sync aparecem — a UI muitas vezes só mostra o resumo. Para o cenário C, `kubeseal --format yaml --controller-namespace kube-system` lê um Secret comum do stdin e escreve o `SealedSecret` no stdout.
</details>

---
