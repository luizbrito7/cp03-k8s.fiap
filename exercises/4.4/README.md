#### Exercício 4.4 — Desafio: canary manual medido, e o que o KEDA faria diferente

**Tempo estimado:** 60 min · *Desafio integrador (com componente serverless)*

- **Objetivo:** implementar um canary apenas com objetos nativos, medir empiricamente a divisão de tráfego e contrastar com o modelo orientado a eventos do KEDA.
- **Enunciado:** implemente um canary da `store-api` com dois Deployments — `store-api-stable` (imagem `1.0`, labels `app: store-api, version: stable`) e `store-api-canary` (imagem `2.0`, labels `app: store-api, version: canary`) — e **um único** Service `store-api` cujo selector é apenas `app: store-api`. Configure a proporção 9:1 (9 réplicas stable, 1 canary). Modifique o endpoint `/info` para retornar também a versão da imagem. A partir de um Pod cliente, dispare **500 requisições** e conte quantas caíram em cada versão:

  ```bash
  kubectl -n store-dev run cliente --rm -it --image=curlimages/curl --restart=Never -- sh -c \
    'for i in $(seq 1 500); do curl -s http://store-api/info; echo; done' | sort | uniq -c | sort -rn
  ```

  Registre o percentual medido, compare com os 10% teóricos e **explique a diferença** (considere `sessionAffinity`, keep-alive de conexão HTTP e o algoritmo do kube-proxy). Depois ajuste a proporção para 8:2 e refaça a medição. **Parte serverless:** instale o KEDA (`helm repo add kedacore https://kedacore.github.io/charts && helm install keda kedacore/keda -n keda --create-namespace`) e escreva um `ScaledObject` para o `store-worker` com `minReplicaCount: 0`, `maxReplicaCount: 10` e um trigger `cron` (ou, se preferir, `prometheus`). Escreva um comparativo de **até 400 palavras** respondendo: (i) o canary por réplicas consegue granularidade de 1%? A que custo? (ii) o que muda quando o roteamento é por peso no Ingress em vez de por contagem de Pods? (iii) por que o `store-worker` é candidato natural a scale-to-zero e a `store-api` não é? (iv) estime o custo mensal das duas abordagens supondo 2 h/dia de trabalho efetivo.
- **Entregável:** `e44-stable.yaml`, `e44-canary.yaml`, `e44-service.yaml`, `e44-scaledobject.yaml`, a saída bruta da contagem nas duas proporções e o comparativo em `e44-analise.md`.
- **Critério de aceite:** a contagem de 500 requisições mostra o canary recebendo entre 5% e 15% na proporção 9:1 e entre 15% e 25% na 8:2; `kubectl -n store-dev get scaledobject` mostra o objeto `READY=True`; `kubectl -n store-dev get deploy store-worker` mostra `0/0` réplicas fora da janela do trigger e ao menos 1 réplica dentro dela; o comparativo responde objetivamente aos quatro itens.
- <details><summary>Dica</summary>Para a medição ser justa, use `curl` com conexões novas a cada requisição (o comportamento padrão do loop acima) — reutilizar a conexão fixa o destino e distorce o resultado. Confirme os endpoints do Service com `kubectl -n store-dev get endpointslice -l kubernetes.io/service-name=store-api -o wide`.</details>
