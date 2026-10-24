#!/usr/bin/env bash
set -euo pipefail
export DOCKER_CONTEXT=rootless
export DOCKER_HOST=unix:///run/user/1000/docker.sock # trivy le o docker rootless por aqui
T="trivy image --no-progress --skip-version-check -q"

# antes: requirements original do app (fastapi 0.115.6 / uvicorn 0.34.0)
cp ../../app/store-api/requirements.txt requirements.txt
docker build -f Dockerfile.vuln -t store-api:vuln .
$T --severity HIGH,CRITICAL store-api:vuln > relatorio-antes.txt
docker run --rm store-api:vuln id
docker run --rm store-api:vuln ls -la /app

# depois: requirements com as versoes corrigidas + distroless
git checkout requirements.txt
docker build -t store-api:1.1 .
$T --severity HIGH,CRITICAL store-api:1.1 > relatorio-depois.txt
$T --format cyclonedx -o store-api-sbom.json store-api:1.1
jq '.components | length' store-api-sbom.json
docker run -d --name t11 store-api:1.1
docker exec t11 python3 -c "import os; print('uid', os.getuid())"   # sem id/sh no distroless
docker rm -f t11

# corrigiveis x total
$T --severity HIGH,CRITICAL --ignore-unfixed store-api:vuln
$T --severity HIGH,CRITICAL --ignore-unfixed store-api:1.1

docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}' | grep -E 'store-api:(vuln|1.1)'
docker image inspect store-api:vuln store-api:1.1 -f '{{.RepoTags}} {{.Size}}'

# porta de qualidade no CI
trivy image --exit-code 1 --ignore-unfixed --severity CRITICAL,HIGH store-api:1.1
