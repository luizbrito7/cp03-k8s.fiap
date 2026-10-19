#### Exercício 4.3 — Depuração: três rollouts quebrados

**Tempo estimado:** 45 min · *Análise / depuração*

- **Objetivo:** diagnosticar sistematicamente falhas de rollout, distinguindo causa raiz de sintoma.
- **Enunciado:** você receberá (ou construirá) três cenários com defeito, e para cada um deve produzir um **laudo** contendo: sintoma observado, comando que revelou a causa, causa raiz e correção aplicada.
  - **Cenário A — imagem inexistente:** faça `kubectl set image deployment/store-api store-api=store-api:9.9`. O `rollout status` deve travar. Explique por que os Pods da versão anterior **continuam servindo tráfego normalmente** e por que isso é uma virtude do RollingUpdate com `maxUnavailable: 0`.
  - **Cenário B — readiness quebrada:** aplique uma revisão em que a `readinessProbe` aponta para `/pronto` (endpoint que não existe) na porta 8000. Diagnostique e explique a diferença de comportamento se o defeito estivesse na `livenessProbe` em vez da readiness.
  - **Cenário C — PDB bloqueando drain:** com `minAvailable: 3` e 3 réplicas, tente `kubectl drain` em um nó que hospeda ao menos um Pod da `store-api`. Explique a mensagem de erro, calcule qual é o maior `minAvailable` que ainda permite drenar um nó com 3 réplicas bem distribuídas, e corrija.
- **Entregável:** `e43-laudo.md` com os três laudos (sintoma, comando de diagnóstico com a saída real colada, causa raiz, correção), mais os manifestos corrigidos.
- **Critério de aceite:** cada laudo cita ao menos um comando de diagnóstico com a saída real (não inventada) — respectivamente `ImagePullBackOff` no `get pods`, `Readiness probe failed: HTTP probe failed with statuscode: 404` no `describe pod`, e `Cannot evict pod as it would violate the pod's disruption budget` no `drain`; ao final dos três, `kubectl -n store-dev get deploy store-api` mostra READY completo e `kubectl drain` conclui com sucesso.
- <details><summary>Dica</summary>No cenário B, lembre que readiness tira o Pod dos Endpoints do Service mas não o reinicia; liveness reinicia o container em loop (`CrashLoopBackOff`). No cenário C, o PDB é avaliado sobre Pods **prontos**, e o substituto precisa ficar Ready antes do próximo despejo.</details>
