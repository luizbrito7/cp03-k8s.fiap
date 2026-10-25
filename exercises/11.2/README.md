#### Exercício 11.2 — Promoção de dev para prod por PR com Kustomize overlays (aplicação) · 50 min

**Objetivo:** implementar a promoção controlada de uma versão entre ambientes usando pull request, sem duplicar manifestos.

**Enunciado:** partindo do repositório do exercício anterior, crie `overlays/prod/` com: namespace `store-prod`, 4 réplicas, `APP_ENV=prod`, recursos maiores, um `PodDisruptionBudget` (`minAvailable: 2`) e um patch com `terminationGracePeriodSeconds: 60` — tudo reaproveitando `base/` via `resources: [../../base]`, **sem copiar** o Deployment. Crie a Application `fiap-store-prod` apontando para `overlays/prod` com tag `1.0`, e um `AppProject` chamado `fiap-store` que permita **apenas** este repositório e **apenas** os namespaces `store-dev` e `store-prod`, com `clusterResourceWhitelist` restrito a `Namespace`. Ambas as Applications devem pertencer a esse projeto.

Em seguida, simule uma release: publique `store-api:1.1`, altere a tag em `overlays/dev` (commit direto), verifique que dev reconcilia. Depois, **abra um pull request** alterando apenas `overlays/prod/kustomization.yaml` de `1.0` para `1.1`, revise o diff, faça o merge e observe prod reconciliar. Documente o diff exato do PR de promoção.

**Entregável:** árvore do repositório (`tree`); os dois `kustomization.yaml` de overlay; o `AppProject` em YAML; link/print do PR de promoção com o diff; saída de `kubectl get deploy,pdb -n store-dev` e `-n store-prod` mostrando as diferenças; e saída de `argocd app list`.

**Critério de aceite:** o diff do PR de promoção contém **no máximo 2 linhas alteradas**; os dois ambientes coexistem com imagens diferentes comprovadas por `kubectl get deploy -n store-dev -o jsonpath='{.items[*].spec.template.spec.containers[*].image}'` e o equivalente em prod; ambas as Applications aparecem com `PROJECT: fiap-store`; e tentar criar uma Application apontando para `kube-system` é rejeitada pelo AppProject.

<details><summary>Dica</summary>
`kustomize edit set image docker.io/SEU-USUARIO/store-api=docker.io/SEU-USUARIO/store-api:1.1` altera a tag sem editar YAML à mão — é exatamente o comando que o CI usará no exercício 11.4. Para testar a rejeição do AppProject, aplique uma Application com `destination.namespace: kube-system` e leia a mensagem em `kubectl describe application`.
</details>

---
