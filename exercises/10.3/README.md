#### Exercício 10.3 — Depuração: aplicação matando conexões no rolling update (análise) · 45 min

**Objetivo:** reproduzir, diagnosticar e corrigir perda de requisições durante um rolling update.

**Enunciado:** você recebeu o seguinte chamado: *"toda vez que a equipe faz deploy da `store-api`, o monitoramento acusa um pico de 502 e alguns clientes veem carrinho vazio"*. Reproduza o cenário: aplique um Deployment da `store-api` com 3 réplicas **sem** `readinessProbe`, **sem** `lifecycle.preStop`, com `terminationGracePeriodSeconds: 5`, `strategy.rollingUpdate.maxUnavailable: 1` e com o `ENTRYPOINT` do Dockerfile em shell form (`ENTRYPOINT sh -c "uvicorn main:app --host 0.0.0.0 --port 8000"`). Suba um gerador de carga contínuo contra o Service e dispare um `kubectl set image` para uma nova tag, **contando** quantas requisições falharam. Em seguida, aplique as correções uma a uma, medindo a taxa de falha após cada uma: (a) adicionar `readinessProbe` em `/ready`; (b) adicionar `preStop` com `sleep 10` e `terminationGracePeriodSeconds: 45`; (c) trocar o `ENTRYPOINT` para forma exec; (d) definir `maxUnavailable: 0` e `maxSurge: 1`; (e) implementar o `lifespan` do FastAPI que faz `/ready` responder 503 no shutdown. Documente a taxa de falha em cada etapa.

**Entregável:** o YAML "quebrado" e o YAML final corrigido; o script/comando do gerador de carga; uma tabela com "correção aplicada × requisições falhadas em 100" para as 5 etapas; saída de `kubectl describe pod` de um Pod em `Terminating` mostrando o `preStop`; e um parágrafo explicando **por que** os Endpoints e o SIGTERM correm em paralelo.

**Critério de aceite:** a versão quebrada apresenta falhas mensuráveis (> 0) durante o rollout; a versão final apresenta **zero** falhas em pelo menos 500 requisições consecutivas durante um rollout completo; e a explicação identifica corretamente a corrida entre a atualização dos Endpoints/iptables e o envio do SIGTERM.

<details><summary>Dica</summary>
Conte falhas com `wget -q -O- --timeout=2 ... && echo OK || echo FALHA` num laço, canalizando para `sort | uniq -c`. Para provar que o shell form engole sinais, rode `kubectl exec -- ps -o pid,comm` e veja quem é o PID 1.
</details>

---
