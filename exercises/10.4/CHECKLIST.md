# CHECKLIST de produção (seção 10.14) aplicado ao `store-prod`

Legenda: `[x]` atendido · `[ ]` não atendido · `[-]` não aplicável.

**Placar: 30 `[x]` + 3 `[-]` = 33 de 41 (80,5%). 8 `[ ]`, todos com justificativa.**

## Imagem e build

- [x] **Imagem base mínima, multi-stage.** `store-api:1.3` é multi-stage com base distroless `python3-debian13`. Front e redis usam imagens Alpine oficiais.
- [x] **`USER` numérico não-root.** `store-api`: `USER 65532:65532`. `nginx-unprivileged`: `USER 101`. A imagem do redis não define usuário, então o Pod força `runAsUser: 999`.
- [x] **Tag imutável ou digest.** Em prod, nginx e redis são fixados por `digest` no overlay. A `store-api` é imagem local carregada no kind (sem registry, não há digest de registry), com tag versionada que nunca é reaproveitada (`1.3`).
- [x] **Scan sem CRITICAL corrigível.** O `make scan` roda `trivy --exit-code 1 --ignore-unfixed --severity CRITICAL`. Ele **reprovou** o nginx 1.27 (CVE-2026-31789 no OpenSSL), o que levou à troca para o 1.30.
- [ ] **SBOM e Cosign.** O SBOM CycloneDX foi gerado no 10.2, mas não há assinatura Cosign: sem registry, não há onde publicar a assinatura.
- [x] **`.dockerignore`.** Cobre `.git`, `.env`, `*.pem` e `*.key`.
- [-] **Registry privado com scan on push.** No lab, as imagens são carregadas direto nos nós com `kind load`. Em AWS seria o ECR com scan on push e lifecycle policy.

## Segurança do workload

- [x] **`runAsNonRoot`, `runAsUser`, `allowPrivilegeEscalation: false`** nos 4 Deployments (base).
- [x] **`readOnlyRootFilesystem` com `emptyDir`.** `/tmp` na api e no front, `/data` no redis.
- [x] **`drop: ["ALL"]` e `seccompProfile: RuntimeDefault`** nos 4.
- [x] **PSA.** `store-prod` em `enforce: restricted`. `store-dev` em `baseline` com `warn: restricted`, para dev avisar sem bloquear experimentos.
- [x] **`automountServiceAccountToken: false`** no Pod e na ServiceAccount.
- [x] **ServiceAccount dedicada, menor privilégio.** Uma por app, sem nenhum RoleBinding, porque nenhum app usa a API.
- [x] **NetworkPolicy default-deny com allow explícito.** 6 políticas, testadas: o front de prod chega na api, o worker não, e o front de dev não chega na api de prod.
- [ ] **Secrets fora do Git, encryption at rest.** O pacote não tem Secrets, mas o etcd do kind não tem `EncryptionConfiguration`. Fica para o Sealed Secrets do capítulo 11.
- [x] **Sem `hostNetwork`, `hostPID`, `hostPath` ou `privileged`.** Comprovado pela reavaliação do PSA `restricted`, sem nenhum aviso.

## Confiabilidade

- [x] **`replicas >= 2` e spread.** api com 3 a 10 réplicas (HPA) e `topologySpreadConstraints` por nó. Front com 3 e worker com 2. O kind tem 3 nós, então o spread é por `hostname`; em EKS seria `topology.kubernetes.io/zone`.
- [x] **`readinessProbe` e `livenessProbe` distintos.** Na api, `/ready` e `/health`. O front tem só readiness, porque o nginx não trava sem cair.
- [-] **`startupProbe`.** O boot leva menos de 2 s.
- [x] **`preStop` e grace.** `preStop.sleep` nativo de 10 s (o distroless não tem `/bin/sleep`) e grace de 45 s na api e 30 s no front.
- [x] **Trata SIGTERM, exec form.** O uvicorn é o PID 1. O distroless nem tem shell, então shell form é impossível.
- [x] **PDB compatível.** `minAvailable: 2` com 3 ou mais réplicas, o que deixa 1 disrupção permitida.
- [x] **`maxUnavailable: 0`** (base).
- [x] **HPA com métrica de carga real.** CPU a 70%. Sob carga, escalou de 3 para 6. O worker escalaria por fila (KEDA, exercício 8.4).

## Recursos

- [x] **`requests` por medição.** Carga de 16.039 requisições em 75 s: a api ficou em 65 a 123m de CPU e 38Mi, e o front em 6 a 11Mi. Daí os requests de 100m/64Mi e 20m/32Mi.
- [x] **`limits` de memória = request.** api 64Mi/64Mi e front 32Mi/32Mi. A QoS fica `Burstable` porque não há limite de CPU (item seguinte).
- [x] **`limits` de CPU omitidos e justificados.** Limite de CPU causa throttling mesmo com o nó ocioso. Sem limite não existe cota CFS, então `container_cpu_cfs_throttled_periods_total` nem é emitido para esses containers (consulta vazia no Prometheus). O que se monitora é o uso real em `container_cpu_usage_seconds_total` (36 séries de `store-prod`, raspadas do kubelet) contra o request.
- [x] **`LimitRange` e `ResourceQuota`** em `store-prod`.
- [x] **`priorityClassName`.** `store-critica` (100000) na api.

## Observabilidade

- [x] **Logs JSON em stdout com `request_id`.** Middleware na api, que reaproveita o `x-request-id` do cliente e devolve o mesmo id no header.
- [ ] **Agregação fora do cluster.** Não há Loki nem CloudWatch no lab.
- [x] **`/metrics` e `ServiceMonitor`.** 3 alvos `up=1` no Prometheus.
- [ ] **Dashboard dos 4 sinais dourados.** O Grafana foi desligado no chart para poupar recursos no kind.
- [x] **Alerta acionável e SLO.** PrometheusRule `StoreApiPoucasReplicas` (`health=ok`). O SLO está no comentário da regra e o runbook vem abaixo.
- [ ] **Tracing (OpenTelemetry).** Não instrumentado.

## Operação

- [ ] **GitOps.** Os manifestos estão em Git com Kustomize, mas são aplicados por `make`. O GitOps (Argo CD) entra no capítulo 11.
- [x] **Runbook.** Ver abaixo.
- [-] **Backup e restauração.** Não há estado persistente: o redis é uma fila efêmera (`--save ""`), e em produção seria SQS (recomendação do 8.4).
- [x] **Plano de upgrade.** Ver abaixo.
- [ ] **Staging equivalente a produção.** O `store-dev` é diferente por desenho, como pede o enunciado (1 réplica, `baseline`, sem PDB).
- [ ] **Custos por namespace.** Os labels `app.kubernetes.io/part-of` existem, mas não há OpenCost/Kubecost instalado.

## Runbook: StoreApiPoucasReplicas

1. `kubectl -n store-prod get pods -l app=store-api -o wide`: identificar os Pods que não estão `1/1`.
2. `kubectl -n store-prod describe pod <pod>`: procurar em Events `FailedScheduling` (quota ou recursos), `Unhealthy` (probe) ou `OOMKilled`.
3. `kubectl -n store-prod logs <pod> --previous`: erro de aplicação. Use o `request_id` do log JSON para correlacionar.
4. Se o problema começou num deploy: `kubectl -n store-prod rollout undo deploy/store-api`.
5. Se for `FailedScheduling` por quota: `kubectl -n store-prod describe quota`. Não aumente a quota sem revisar o HPA (`maxReplicas`).

## Plano de upgrade

- **Cluster:** uma minor por vez (1.36 → 1.37), control plane antes dos nós. Antes de subir, rodar `kubectl apply -k ... --dry-run=server` contra a versão nova para pegar APIs removidas. Os PDBs garantem a drenagem nó a nó sem queda.
- **Imagens:** bump de tag ou digest no overlay, `make scan`, `make diff`, `make deploy-prod`. O rollback é o `rollout undo` ou o digest anterior no Git.
- **Operadores (kube-prometheus-stack, KEDA, metrics-server):** versões fixadas no Helm. Sobem primeiro em dev e ficam uma semana lá antes de prod.
