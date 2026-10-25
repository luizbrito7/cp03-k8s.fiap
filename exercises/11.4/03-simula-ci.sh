#!/usr/bin/env bash
# Reproduz localmente os passos do .github/workflows/ci.yaml (sem GitHub Actions no lab).
# Diferencas: push -> kind load; create-pull-request -> API do Gitea.
set -euo pipefail
RUN=${RUN:-1}                       # equivale ao github.run_number
APP=~/study/store-api-app
IMAGEM=store-api
export DOCKER_CONTEXT=rootless DOCKER_HOST=unix:///run/user/1000/docker.sock
source ~/study/cp03-k8s.fiap/assets/gitea-admin.env

cd $APP
"$VENV"/bin/pytest -q                                                    # Testes
docker build -q --build-arg APP_VERSION=$RUN -t $IMAGEM:$RUN .          # Build
trivy image -q --exit-code 1 --severity CRITICAL --ignore-unfixed $IMAGEM:$RUN   # Scan
kind load docker-image $IMAGEM:$RUN --name fiap-store                    # "Push"

# promove-dev: clona o config repo, bump com kustomize, branch e PR
TMP=$(mktemp -d); git clone -q http://localhost:3000/fiap/fiap-store-config.git $TMP; cd $TMP
git checkout -qb bump/store-api-$RUN
(cd overlays/dev && kustomize edit set image store-api=$IMAGEM:$RUN)
git -c user.name=ci -c user.email=ci@local.test commit -qam "chore(dev): bump store-api to $RUN"
git -c credential.helper="!f(){ echo username=$GITEA_USER; echo password=$GITEA_PASS; }; f" push -q -u origin bump/store-api-$RUN
curl -s -u "$GITEA_USER:$GITEA_PASS" -H Content-Type:application/json \
  -X POST localhost:3000/api/v1/repos/fiap/fiap-store-config/pulls \
  -d "{\"head\":\"bump/store-api-$RUN\",\"base\":\"main\",\"title\":\"dev: store-api $RUN\",\"body\":\"Gerado pelo CI da store-api (run $RUN). Testes e scan aprovados.\"}" \
  | jq -r '"PR #\(.number) \(.html_url)"'
git diff HEAD~1
