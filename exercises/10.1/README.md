#### Exercício 10.1 — Endurecimento com `securityContext` e PSA (fixação guiada) · 30 min

**Objetivo:** aplicar um `securityContext` restrito à `store-api` e comprovar que o namespace rejeita workloads privilegiados.

**Enunciado:** crie o namespace `store-seguro` com as três labels de Pod Security Admission no perfil `restricted` (`enforce`, `audit`, `warn`), fixando `enforce-version` na versão do seu cluster. Escreva `store-api-restrito.yaml` com um Deployment de 2 réplicas da `store-api` contendo, no mínimo: `runAsNonRoot: true`, `runAsUser: 65532`, `fsGroup: 65532`, `seccompProfile: RuntimeDefault` (nível Pod) e `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: ["ALL"]` (nível container), mais um `emptyDir` montado em `/tmp`. Em seguida escreva `pod-privilegiado.yaml` com `privileged: true` e tente aplicá-lo no mesmo namespace. Por fim, crie um segundo namespace `store-legado` com `enforce: baseline` e aplique nele o **mesmo** Pod privilegiado, registrando a diferença de comportamento.

**Entregável:** os três arquivos YAML; saída de `kubectl get ns store-seguro --show-labels`; saída completa do erro de `kubectl apply -f pod-privilegiado.yaml -n store-seguro`; saída de `kubectl get pods -n store-seguro -o wide`; saída de `kubectl exec -n store-seguro deploy/store-api -- id`; e um parágrafo comparando os resultados nos dois namespaces.

**Critério de aceite:** os 2 Pods da `store-api` em `Running 1/1` no namespace `restricted`; o `id` retornando `uid=65532`; a aplicação do Pod privilegiado rejeitada com `Error from server (Forbidden): ... violates PodSecurity "restricted"` listando pelo menos 4 violações; e o mesmo Pod também rejeitado (ou explicitamente aceito, com justificativa) no namespace `baseline`.

<details><summary>Dica</summary>
Se o Pod ficar em `CreateContainerConfigError` depois de ligar `readOnlyRootFilesystem`, o uvicorn está tentando escrever em `/tmp` — monte o `emptyDir`. Se o Deployment ficar `0/2` sem criar Pods, o erro está no ReplicaSet: `kubectl describe rs -n store-seguro`.
</details>

---
