## Comparativo: canary por réplicas x KEDA

**(i) Granularidade de 1%.** Por contagem de réplicas o percentual é `canary / total`. Para 1% são 99 stable + 1 canary: 100 Pods só para controlar o peso, mesmo que 4 dessem conta da carga. O custo é capacidade ociosa (CPU e memória reservadas por `requests`), mais nós e mais tempo de rollout. Na prática fica preso a degraus de 10% ou 20% com poucas réplicas, e o resultado ainda varia: medi 10,1% em 9:1 e 17,5% em 8:2.

**(ii) Peso no Ingress.** Com roteamento por peso (anotações `canary-weight` do ingress-nginx, Gateway API `HTTPRoute` com `weight` ou um service mesh) o proxy decide o destino de cada requisição. A proporção deixa de depender do número de Pods: 1% com 1 Pod canary e 2 stable. Também dá para rotear por header ou cookie (testers internos) e o escalonamento de cada versão fica livre, por exemplo com HPA.

**(iii) Scale-to-zero.** O `store-worker` processa pedidos em lote: não tem cliente esperando resposta, então o atraso de subir um Pod (cold start de segundos) é irrelevante e existe um gatilho natural (fila, cron). A `store-api` atende requisições síncronas do usuário; com 0 réplicas a primeira requisição cairia em erro ou esperaria o Pod subir, o que quebra a experiência e a readiness. Ela precisa de mínimo maior que zero.

**(iv) Custo mensal, preço Fargate us-east-1** ([página oficial](https://aws.amazon.com/fargate/pricing/): US$ 0,000011244 por vCPU-segundo e US$ 0,000001235 por GB-segundo, ou seja US$ 0,04048/vCPU-h e US$ 0,00445/GB-h). Pod do worker com 0,25 vCPU e 0,5 GB = US$ 0,01234/h. Duas réplicas:

| Abordagem | Horas/mês | Custo/mês |
| --- | --- | --- |
| Worker sempre ligado (Deployment comum) | 2 × 720 = 1.440 | US$ 17,77 |
| Worker com KEDA, 2 h/dia | 2 × 60 = 120 | US$ 1,48 |

Economia de cerca de 92%. O control plane do EKS (US$ 0,10/h, [página oficial](https://aws.amazon.com/eks/pricing/), US$ 72/mês) é igual nos dois cenários, e o próprio KEDA roda nos nós do cluster. O canary por réplicas tem o efeito contrário: para 1%, 100 Pods iguais a esse custariam cerca de US$ 888/mês contra US$ 26,66/mês de 3 Pods com peso no Ingress.
