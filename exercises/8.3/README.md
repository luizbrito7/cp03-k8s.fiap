#### Exercício 8.3 — Depuração: Job estourado, Secret inválido e Service sem endpoints
*Tempo estimado: 35 min · Nível: análise/depuração*

- **Objetivo:** diagnosticar três falhas distintas de batch, configuração sensível e descoberta de serviço.
- **Enunciado:** reproduza os três cenários abaixo e, para **cada um**, registre: (i) o STATUS/estado observado, (ii) o comando que revelou a causa e a mensagem exata, (iii) a correção aplicada, (iv) a evidência da correção.
  - **Cenário A:** Job `relatorio-quebrado` com `backoffLimit: 2`, `restartPolicy: Never`, cujo comando sai com código 1 (por exemplo, tentando ler um arquivo inexistente). Observe as tentativas, os Pods `Error` acumulados e a condição final do Job.
  - **Cenário B:** Secret criado por manifesto usando o campo `data:` com um valor **que não é base64 válido** e, na sequência, um segundo Secret com base64 válido porém gerado **com quebra de linha** (`echo 'senha' | base64`, sem o `-n`). Mostre o erro do primeiro e prove, no segundo, que a senha chega ao container com um `\n` a mais — comparando o tamanho esperado com `${#VAR}` ou `wc -c`.
  - **Cenário C:** Deployment `store-api` com label `app: store-api` e Service com `selector: app: storeapi` (sem hífen). Mostre o EndpointSlice vazio, prove a falha de conexão a partir de outro Pod e corrija. Em seguida, provoque a **mesma** falha de forma diferente: mantenha o selector correto mas quebre a `readinessProbe` (aponte para `/pronto`, que não existe) e mostre que o endpoint some com o Pod ainda `Running`.
- **Entregável:** `DEPURACAO.md` com as 4 informações por cenário; os manifestos quebrados e corrigidos; saídas de `kubectl describe job`, `kubectl get pods`, `kubectl get endpointslices -o wide` e do teste de conexão.
- **Critério de aceite:** o Cenário A apresenta `reason: BackoffLimitExceeded` e exatamente 3 Pods em `Error` (1 tentativa + 2 retentativas); o Cenário B apresenta a mensagem `illegal base64 data` e a evidência numérica do caractere extra; o Cenário C mostra `ENDPOINTS` vazio nas duas causas distintas e populado após cada correção.
- **Dica:**
  <details><summary>Dica</summary>
  Em <code>restartPolicy: Never</code>, cada retentativa cria um Pod novo — conte-os. Na readinessProbe, o Pod fica <code>1/1 Running</code>? Confira <code>kubectl get pod</code> na coluna READY e o <code>describe</code> na seção Conditions (<code>Ready: False</code>, <code>ContainersReady: False</code>).
  </details>
