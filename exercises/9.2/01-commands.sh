#!/usr/bin/env bash
set -uo pipefail # sem -e: as etapas (a) e (d) falham de proposito
J="kubectl --kubeconfig=./kubeconfig-joao.yaml"

# identidade: chave, CSR, CertificateSigningRequest, aprovacao, certificado
openssl genrsa -out joao-qa.key 2048
openssl req -new -key joao-qa.key -out joao-qa.csr -subj "/CN=joao.qa/O=fiap:qa"
sed -i "s|request: .*|request: $(base64 -w0 joao-qa.csr)|" csr-joao.yaml
kubectl apply -f csr-joao.yaml
kubectl certificate approve joao.qa
kubectl get csr joao.qa -o jsonpath='{.status.certificate}' | base64 -d > joao-qa.crt
openssl x509 -in joao-qa.crt -noout -subject -dates

# kubeconfig autocontido (--embed-certs)
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
K=kubeconfig-joao.yaml
kubectl --kubeconfig=$K config set-cluster kind-fiap-store --server=$SERVER --certificate-authority=ca.crt --embed-certs=true
kubectl --kubeconfig=$K config set-credentials joao.qa --client-certificate=joao-qa.crt --client-key=joao-qa.key --embed-certs=true
kubectl --kubeconfig=$K config set-context joao.qa@fiap-store --cluster=kind-fiap-store --user=joao.qa --namespace=store-dev
kubectl --kubeconfig=$K config use-context joao.qa@fiap-store
rm ca.crt

# (a) sem binding: 403 (autenticado, nao autorizado)
$J get pods -n store-dev -v=6
$J auth whoami

# (b) e (c) binding por grupo + exec so em store-dev
kubectl apply -f rbac-qa.yaml
$J get pods -n store-dev
kubectl auth can-i list pods -n store-dev --as=joao.qa                        # no: o usuario sozinho nao tem binding
kubectl auth can-i list pods -n store-dev --as=joao.qa --as-group=fiap:qa     # yes: veio do grupo
$J exec -n store-dev <pod> -- sh -c 'echo exec ok em $(hostname)'
$J exec -n store-prod alvo -- sh -c 'echo exec ok'
$J auth can-i create pods --subresource=exec -n store-dev
$J auth can-i create pods --subresource=exec -n store-prod

# (d) revogacao: continua 403, nao 401
kubectl delete -f rbac-qa.yaml
$J get pods -n store-dev -v=6
