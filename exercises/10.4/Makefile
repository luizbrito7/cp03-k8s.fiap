# uso: make deploy-dev | deploy-prod | scan | diff | destroy
export DOCKER_CONTEXT ?= rootless
export DOCKER_HOST ?= unix:///run/user/1000/docker.sock
export KUBECONFIG ?= $(abspath ../../assets/kubeconfig)
IMAGENS = store-api:1.3 nginxinc/nginx-unprivileged:1.30-alpine redis:7-alpine

.PHONY: deploy-dev deploy-prod scan diff destroy

deploy-dev:
	kubectl apply -k k8s/overlays/dev
	kubectl -n store-dev rollout status deploy --timeout=180s

deploy-prod:
	kubectl apply -k k8s/overlays/prod
	kubectl -n store-prod rollout status deploy --timeout=180s

scan:
	for i in $(IMAGENS); do trivy image -q --exit-code 1 --ignore-unfixed --severity CRITICAL $$i || exit 1; done

diff:
	-kubectl diff -k k8s/overlays/dev
	-kubectl diff -k k8s/overlays/prod

destroy:
	kubectl delete -k k8s/overlays/prod --ignore-not-found
	kubectl delete -k k8s/overlays/dev --ignore-not-found
