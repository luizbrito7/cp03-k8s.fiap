#### Exercício 9.3 — Depuração: quatro erros "Forbidden" reais
*Tempo estimado: 40 min · Nível: análise/depuração*

- **Objetivo:** interpretar mensagens de autorização e corrigi-las com o **mínimo** de permissão adicional.
- **Enunciado:** para cada cenário, reproduza o erro, transcreva a mensagem **exata**, identifique os cinco elementos que ela informa (sujeito, verbo, recurso, apiGroup, namespace), e aplique a **menor** alteração de RBAC que o resolve. Prove que a correção foi mínima mostrando um `can-i` que continua retornando `no` para algo adjacente.
  - **Cenário A:** uma Role concede `pods` com `["get","list","watch"]`, mas o usuário roda `kubectl logs`. Explique por que falha e corrija.
  - **Cenário B:** uma Role concede `resources: ["deployments"]` com `apiGroups: [""]` (core). O usuário não consegue listar Deployments. Identifique o erro e corrija sem ampliar mais nada.
  - **Cenário C:** uma Role concede `["create","update"]` sobre `deployments` no apiGroup `apps`. O usuário roda `kubectl apply -f deploy.yaml` e recebe `Forbidden`. Descubra quais verbos o `apply` realmente exige e corrija.
  - **Cenário D:** um `RoleBinding` no namespace `store-dev` referencia a ClusterRole `edit`, mas o usuário tenta operar em `store-prod`. Além de corrigir, explique por que trocar por `ClusterRoleBinding` seria a solução **errada** e qual é a correta.
  Para cada cenário use `kubectl auth can-i --as=<usuario>` como ferramenta principal de diagnóstico.
- **Entregável:** `DEPURACAO.md` contendo, por cenário: a mensagem exata de erro, a tabela dos cinco elementos extraídos, o diff do YAML da Role (antes/depois), a saída de `can-i` provando a correção e a saída de `can-i` provando que a permissão adjacente continua negada.
- **Critério de aceite:** os quatro cenários apresentam mensagens de erro reais capturadas do cluster (não inventadas); a correção do Cenário A adiciona **apenas** `pods/log` (não `pods/exec`); a do Cenário C adiciona **apenas** `get` e `patch`; e no Cenário D a solução é um segundo RoleBinding em `store-prod`, com justificativa escrita contra o `ClusterRoleBinding`.
- **Dica:**
  <details><summary>Dica</summary>
  Rode <code>kubectl apply -v=8</code> para ver as requisições HTTP reais que o comando faz — é o jeito mais direto de descobrir os verbos exigidos no Cenário C.
  </details>
