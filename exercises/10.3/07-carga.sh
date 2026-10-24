#!/bin/sh
# gerador de carga: N requisicoes sequenciais ao Service, timeout 2s, ~10/s
# uso (dentro do Pod carga): sh /carga.sh 600
N=${1:-600}
i=0
while [ $i -lt $N ]; do
  if wget -q -O /dev/null -T 2 http://store-api/versao; then echo OK; else echo FALHA; fi
  i=$((i + 1))
  sleep 0.1
done | sort | uniq -c
