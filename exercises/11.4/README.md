#### Exercício 11.4 — Desafio: App-of-Apps/ApplicationSet + CI que atualiza a tag (desafio integrador) · 60 min

**Objetivo:** colocar toda a FIAP Store sob um único ponto de entrada GitOps em dois namespaces e automatizar o bump de imagem pelo CI.

**Enunciado:** monte a solução completa em duas partes.

**Parte 1 — gestão declarativa da frota.** Escolha **um** dos padrões e justifique a escolha em 5 linhas:

- **App-of-Apps:** uma Application raiz `fiap-store-root` apontando para `apps/`, que contém `store-dev.yaml`, `store-prod.yaml` e `infra.yaml` (este último instalando as policies Kyverno do capítulo 10).
- **ApplicationSet:** um `ApplicationSet` com gerador `git` por diretório (`directories: [{path: overlays/*}]`) ou gerador `list` com os elementos `dev` e `prod`.

O resultado deve ser que **um único `kubectl apply`** faça subir `store-api`, `store-front` e `store-worker` nos namespaces `store-dev` e `store-prod`, com configurações distintas por ambiente e com o `AppProject` `fiap-store` aplicado. Use `sync-wave` para garantir que o namespace e as policies sejam criados antes das aplicações, e adicione um hook `PreSync` que rode um Job de validação (pode ser um `echo` didático que verifica a conectividade com o `store-db`).

**Parte 2 — CI que promove automaticamente.** Crie no app repo um workflow do GitHub Actions que, a cada push na `main`: rode os testes, construa a imagem com tag baseada em `github.run_number`, escaneie com Trivy (`--exit-code 1 --severity CRITICAL --ignore-unfixed`), faça push, e então clone o config repo, execute `kustomize edit set image` em `overlays/dev` e **abra um PR**. Faça o merge desse PR e comprove que o Argo CD sincroniza `store-dev` com a nova tag sem nenhuma ação sua no cluster. Demonstre que **não existe nenhum `KUBECONFIG` nem `kubectl` no workflow**.

**Componente serverless (obrigatório):** adicione ao repositório um `Knative Service` equivalente à `store-api` (com `minScale: 0` e `maxScale: 20`) em `overlays/serverless/`, e crie uma Application para ele. Se não tiver o Knative instalado, entregue o manifesto e um `kubectl apply --dry-run=client` válido, mais uma análise de 10 a 15 linhas respondendo: (a) por que `minScale: 0` **não** conflita com a reconciliação contínua do Argo; (b) quais campos você precisaria colocar em `ignoreDifferences` e por quê; (c) o que muda no `ApplicationSet` se metade dos ambientes for Knative e metade Deployment.

**Entregável:** árvore completa do config repo; o YAML do App-of-Apps **ou** do ApplicationSet; o `AppProject`; o workflow `.github/workflows/ci.yaml`; link/print do PR aberto automaticamente pelo CI; `argocd app list` mostrando todas as Applications geradas; `kubectl get all -n store-dev` e `-n store-prod`; o manifesto Knative; e o texto da análise serverless.

**Critério de aceite:** um único `kubectl apply -f` (do root/ApplicationSet) resulta em pelo menos 4 Applications no `argocd app list`, todas `Synced/Healthy`; os dois namespaces têm configurações comprovadamente distintas; o PR de bump foi criado pelo CI **sem intervenção manual**; o workflow não contém nenhuma credencial de cluster; e a análise serverless responde corretamente aos três pontos, identificando que o Argo compara `spec` (intenção) e não a contagem de Pods (execução).

<details><summary>Dica</summary>
Com `goTemplate: true` no ApplicationSet, use `{{.path.basename}}` no gerador `git` para nomear a Application a partir do nome da pasta. Para o PR automático, `peter-evans/create-pull-request@v7` exige um PAT com escopo `repo` no config repo (o `GITHUB_TOKEN` padrão não cruza repositórios). Se o hook `PreSync` reexecutar e falhar, faltou `hook-delete-policy: HookSucceeded`.
</details>

---
