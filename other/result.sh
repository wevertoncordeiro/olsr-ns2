#!/bin/bash

PROTO=$1

for i in $(seq 1 10); do
  printf "jitter num\t\tatraso num\t\tvazao num\t\tbloqueio\n"
  for j in $(seq 1 12); do
    JITTER=$(awk '{print $2" "$3}' sim-$i-$PROTO/jitter$j.jit.avg)
    ATRASO=$(awk '{print $2" "$3}' sim-$i-$PROTO/atraso$j.del.avg)
    VAZAO=$(awk '{print $2" "$3}' sim-$i-$PROTO/vazao$j.vaz.avg)
    BLOQUEIO=$(grep "fluxo: $j " sim-$i-$PROTO/bloqueio.blq | awk '{print $9}')
    printf -- "$JITTER\t\t$ATRASO\t\t$VAZAO\t\t$BLOQUEIO\n"
  done
done
