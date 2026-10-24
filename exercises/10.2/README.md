#### Exercício 10.2 — Scan de vulnerabilidades e correção da imagem base (aplicação) · 45 min

**Objetivo:** medir a superfície de vulnerabilidades da `store-api` e reduzi-la trocando a estratégia de build, com relatório antes/depois.

**Enunciado:** construa `store-api:vuln` a partir de um Dockerfile deliberadamente ruim — `FROM python:3.12` (imagem completa), `pip install` sem multi-stage, sem `USER` (roda como root), `COPY . .` sem `.dockerignore`. Escaneie com `trivy image --severity HIGH,CRITICAL` e salve o relatório em `relatorio-antes.txt`, anotando também o tamanho da imagem e o resultado de `docker run --rm store-api:vuln id`. Em seguida reescreva o Dockerfile com multi-stage e base distroless (`gcr.io/distroless/python3-debian12:nonroot`), atualize as dependências no `requirements.txt` para as versões corrigidas apontadas pelo scanner, construa `store-api:1.1` e gere `relatorio-depois.txt`. Gere também o SBOM em CycloneDX (`trivy image --format cyclonedx`). Finalize com uma tabela comparativa contendo: tamanho da imagem, nº de CRITICAL, nº de HIGH, número de pacotes no SBOM e UID do processo.

**Entregável:** os dois Dockerfiles, `.dockerignore`, `relatorio-antes.txt`, `relatorio-depois.txt`, `store-api-sbom.json`, a tabela comparativa em Markdown e o comando de CI com `--exit-code 1 --ignore-unfixed` que você usaria como porta de qualidade.

**Critério de aceite:** redução de pelo menos 80% no tamanho da imagem; zero CVEs CRITICAL **corrigíveis** no relatório depois; o processo rodando com UID != 0 na imagem nova; o SBOM válido e legível (`jq '.components | length' store-api-sbom.json` retorna um número > 0).

<details><summary>Dica</summary>
Rode `trivy image --scanners vuln --ignore-unfixed` para separar o que você consegue corrigir do que depende da distro. Se alguma wheel não instalar no distroless, instale no estágio builder dentro de um venv e copie o venv inteiro — como no Dockerfile da seção 10.4.2.
</details>

---
