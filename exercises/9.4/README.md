#### Exercício 9.4 — Desafio: modelo RBAC completo para quatro perfis em dois namespaces
*Tempo estimado: 60 min · Nível: desafio integrador*

- **Objetivo:** projetar, implementar, documentar e comprovar um modelo de autorização realista de menor privilégio.
- **Enunciado:** desenhe e implemente o modelo de acesso da FIAP Store para os namespaces `store-dev` e `store-prod`, com quatro perfis, representados por **grupos** (não por usuários individuais):
  - **`fiap:dev`** — controle total sobre workloads em `store-dev` (Deployments, Pods, Services, ConfigMaps, Jobs, HPA), incluindo `pods/log` e `pods/exec`; em `store-prod`, **somente leitura** e **sem** acesso a Secrets nem a `pods/exec`.
  - **`fiap:qa`** — leitura em ambos os namespaces, mais permissão de criar e apagar **Jobs** em `store-dev` (para rodar suítes de teste) e `create` sobre `pods/exec` apenas em `store-dev`.
  - **`fiap:sre`** — controle total em ambos os namespaces, incluindo Secrets, PVCs, StatefulSets e DaemonSets, mais leitura cluster-wide de `nodes`, `persistentvolumes`, `storageclasses` e `namespaces` — **sem** ser `cluster-admin`.
  - **`fiap:auditor`** — leitura de **tudo** em ambos os namespaces, incluindo objetos RBAC (`roles`, `rolebindings`), mas **jamais** o conteúdo de Secrets e **sem nenhum** verbo de escrita em lugar nenhum.
  Requisitos de implementação: use ClusterRoles reaproveitadas por RoleBindings sempre que possível; nenhum wildcard em `verbs` ou `resources`; nenhum `ClusterRoleBinding` exceto onde o acesso for genuinamente cluster-wide (perfil SRE); documente a decisão em comentários no YAML. Crie um usuário por certificado para **cada** perfil (ou, alternativamente, quatro ServiceAccounts) para produzir evidências reais. Por fim, produza uma **matriz de permissões** em `MATRIZ.md`: linhas = (recurso, verbo) com pelo menos 14 combinações relevantes; colunas = os 4 perfis × 2 namespaces (8 colunas); células = `yes`/`no` **obtidos da saída real** de `kubectl auth can-i ... --as-group=<grupo> --as=<usuario>`, não do que você espera. Inclua um script `testa-rbac.sh` que gere a matriz automaticamente.
- **Entregável:** `rbac-modelo.yaml` (todas as ClusterRoles, Roles e bindings, com comentários justificando cada decisão), `testa-rbac.sh`, `MATRIZ.md` com a matriz preenchida a partir da saída do script, e um parágrafo final justificando por que o perfil `auditor` **não** usa o ClusterRole `view` como está (ou por que usa).
- **Critério de aceite:** a matriz tem no mínimo 14 linhas × 8 colunas totalmente preenchidas com saídas reais; `fiap:auditor` retorna `no` para todo verbo de escrita e `no` para `get secrets` nos dois namespaces; `fiap:dev` retorna `yes` para `create pods/exec` em `store-dev` e `no` em `store-prod`; `fiap:sre` retorna `yes` para `get nodes` mas `no` para `create clusterrolebindings`; e nenhum arquivo YAML contém `"*"` em `verbs` ou `resources`.
- **Dica:**
  <details><summary>Dica</summary>
  Esqueleto do script: <code>for g in dev qa sre auditor; do for ns in store-dev store-prod; do for c in "get pods" "create jobs" "get secrets" "create pods/exec"; do echo -n "| $(kubectl auth can-i $c -n $ns --as=teste.$g --as-group=fiap:$g) "; done; done; done</code>. Para o auditor, pesquise por que ler <code>rolebindings</code> é considerado privilégio sensível — e considere <code>resourceNames</code> se precisar de granularidade.
  </details>

---
