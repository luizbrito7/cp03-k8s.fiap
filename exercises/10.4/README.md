#### Exercício 10.4 — Desafio: checklist de produção + empacotamento (desafio integrador) · 60 min

**Objetivo:** aplicar o checklist de produção à FIAP Store completa e empacotar os manifestos com Helm ou Kustomize, com overlays de dev e prod.

**Enunciado:** consolide `store-api`, `store-front` e `store-worker` em um único pacote de deploy, **à sua escolha**:

- **Opção Kustomize:** `k8s/base/` com os manifestos comuns e `k8s/overlays/dev` e `k8s/overlays/prod` aplicando as diferenças.
- **Opção Helm:** `charts/fiap-store/` com `values-dev.yaml` e `values-prod.yaml`.

O overlay/values de **dev** deve ter: namespace `store-dev`, 1 réplica, `APP_ENV=dev`, PSA `baseline`, recursos pequenos, sem PDB. O de **prod**: namespace `store-prod`, 3+ réplicas, `APP_ENV=prod`, PSA `restricted`, `securityContext` completo, PDB, HPA, `preStop` + grace period, ServiceMonitor, NetworkPolicy default-deny, LimitRange e ResourceQuota. Aplique **os dois** ambientes no mesmo cluster e comprove que convivem isolados.

Em seguida, produza `CHECKLIST.md` percorrendo **todos** os itens da seção 10.14, marcando cada um como `[x] atendido`, `[ ] não atendido` ou `[-] não aplicável`, com uma linha de justificativa por item não atendido. Adicione um `Makefile` (ou script) com alvos `deploy-dev`, `deploy-prod`, `scan`, `diff` e `destroy`.

**Componente serverless (obrigatório):** escolha **um** dos itens do checklist que deixa de fazer sentido em AWS Lambda e **um** que continua exatamente igual, e explique em até 10 linhas por que a linha de responsabilidade compartilhada se move em um caso e não no outro. Como extra opcional, escreva o manifesto de um `Knative Service` equivalente à `store-api` e compare quantos itens do checklist ele elimina.

**Entregável:** a árvore completa de diretórios (`tree`), saída de `kubectl kustomize k8s/overlays/prod` ou `helm template`, saída de `kubectl get all,pdb,hpa,netpol,quota -n store-prod` e `-n store-dev`, o `CHECKLIST.md` preenchido, o `Makefile` e o texto da análise serverless.

**Critério de aceite:** um único comando (`make deploy-prod` ou `kubectl apply -k`) sobe o ambiente inteiro; os dois namespaces coexistem com configurações comprovadamente distintas (a saída de `kubectl get deploy -n store-dev` e `-n store-prod` difere em réplicas e imagem/tag); nenhum recurso em `store-prod` viola o PSA `restricted`; ao menos 80% dos itens do checklist marcados `[x]` ou `[-]` com justificativa; e a análise serverless identifica corretamente uma responsabilidade transferida e uma retida.

<details><summary>Dica</summary>
Em Kustomize, use `patches` com `target` por `kind`/`name` para não duplicar YAML, e `images:` no overlay para trocar a tag sem editar a base. Em Helm, `{{- if .Values.pdb.enabled }}` mantém o PDB fora de dev. Valide antes de aplicar com `kubectl apply -k k8s/overlays/prod --dry-run=server`.
</details>

---
