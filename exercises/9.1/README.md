#### Exercício 9.1 — ServiceAccount somente-leitura validada com can-i
*Tempo estimado: 25 min · Nível: fixação guiada*

- **Objetivo:** conceder acesso de leitura a uma identidade de workload e validar objetivamente o resultado.
- **Enunciado:** no namespace `store-dev`, crie a ServiceAccount `monitor-sa`, uma Role `leitura-store` que permita apenas `get`, `list` e `watch` sobre `pods`, `services`, `endpoints`, `configmaps` e o subresource `pods/log`, e o RoleBinding correspondente. Em seguida: (a) valide com `kubectl auth can-i` usando impersonation (`--as=system:serviceaccount:store-dev:monitor-sa`) pelo menos **seis** combinações verbo/recurso, incluindo duas que devem retornar `no` (`get secrets` e `create pods`); (b) gere um token com `kubectl create token monitor-sa -n store-dev --duration=1h`, decodifique o payload JWT (`cut -d. -f2 | base64 -d`) e mostre os campos `sub`, `aud` e `exp`; (c) suba um Pod que use essa ServiceAccount e, de dentro dele, chame a API do Kubernetes com `curl` usando o token montado, listando os Pods do namespace e recebendo `403` ao tentar listar Secrets. Documente as evidências em `EVIDENCIAS.md`.
- **Entregável:** `monitor-rbac.yaml` (SA + Role + RoleBinding), `EVIDENCIAS.md` com as seis saídas de `can-i`, o payload JWT decodificado e as duas respostas HTTP do `curl` (200 e 403) com o corpo da mensagem de erro.
- **Critério de aceite:** `kubectl auth can-i --list -n store-dev --as=system:serviceaccount:store-dev:monitor-sa` mostra apenas os recursos concedidos; `get secrets` e `create pods` retornam `no`; o `sub` do JWT é exatamente `system:serviceaccount:store-dev:monitor-sa`; e o `curl` a `/api/v1/namespaces/store-dev/secrets` retorna HTTP 403 com mensagem de `forbidden`.
- **Dica:**
  <details><summary>Dica</summary>
  Dentro do Pod: <code>TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)</code> e <code>curl -sS -k -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/store-dev/pods</code>. Use <code>-w '%{http_code}'</code> para capturar o status.
  </details>
