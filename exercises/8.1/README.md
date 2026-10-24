#### Exercício 8.1 — Job paralelo com logs agregados
*Tempo estimado: 25 min · Nível: fixação guiada*

- **Objetivo:** executar processamento batch paralelo e ler o resultado consolidado das réplicas.
- **Enunciado:** no namespace `store-dev`, crie um Job `processa-pedidos` com `completions: 10` e `parallelism: 3`, `backoffLimit: 4` e `ttlSecondsAfterFinished: 600`. Cada Pod deve imprimir o próprio hostname, dormir um tempo aleatório entre 3 e 8 segundos e imprimir uma linha final `LOTE OK <hostname>`. Acompanhe com `kubectl get job -w` e observe que nunca há mais de 3 Pods `Running` ao mesmo tempo (registre a saída de `kubectl get pods` em pelo menos dois momentos distintos durante a execução). Ao final, colete os logs agregados de todos os Pods de uma só vez usando o seletor `job-name`. Em seguida, crie uma segunda versão do Job com `completionMode: Indexed` e `completions: 4`, fazendo cada Pod imprimir a partição que processou; comprove que os quatro índices de 0 a 3 apareceram, sem repetição.
- **Entregável:** `job-paralelo.yaml`, `job-indexed.yaml`, saídas de `kubectl get job,pods -n store-dev` durante a execução, saída de `kubectl logs -l job-name=processa-pedidos -n store-dev --prefix --tail=1` e a listagem dos 4 índices distintos.
- **Critério de aceite:** `COMPLETIONS` chega a `10/10` com STATUS `Complete`; nenhuma amostra de `kubectl get pods` mostra mais de 3 Pods em `Running`; os logs agregados contêm 10 linhas `LOTE OK`; e no Job Indexed aparecem exatamente os índices 0, 1, 2 e 3.
- **Dica:**
  <details><summary>Dica</summary>
  Todo Pod de um Job recebe automaticamente a label <code>job-name=&lt;nome&gt;</code> (e <code>batch.kubernetes.io/job-name</code> nas versões recentes). Para o tempo aleatório em <code>busybox</code>: <code>sleep $(( (RANDOM % 6) + 3 ))</code>.
  </details>
