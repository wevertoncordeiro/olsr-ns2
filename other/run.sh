#!/bin/bash

DEFAULT_SCRIPT_DIR=default

function calculate_average()
{
  PREFIX=$1
  SUFFIX=$2
  BEGIN=$3
  END=$4

  for i in $(seq $BEGIN $END); do
    FILE_NAME=$PREFIX$i$SUFFIX
    SUM=0

    for i in $(awk '{print $2}' $FILE_NAME); do
      SUM=$(echo $SUM+\(`./conv $i`\) | bc);
    done
    COUNT=$(wc -l $FILE_NAME | awk '{print $1}')
    echo $FILE_NAME $SUM $COUNT >> $FILE_NAME.avg
  done
}

function simulate_protocol()
{
  SEED=$1
  PROTO=$2
  NEWDIR=sim-$SEED-$PROTO

  echo "Creating $NEWDIR..."
  cp -a $PROTO $NEWDIR
  cd $NEWDIR
  sed "s/set opt(seed) X/set opt(seed) $SEED/g" script.tcl > script_run.tcl
  time ns2 script_run.tcl > debug
  time ns2 atsroot.tcl > /dev/null
  time ns2 vzroot.tcl > /dev/null
  TX=0;
  for i in $(awk '{print $6}' bloqueio.blq); do
    TX=$((TX+i));
  done;
  DROPPED=0;
  for i in $(awk '{print $4}' bloqueio.blq); do
    DROPPED=$((DROPPED+i));
  done;
  echo "Packets transmitted $TX , dropped $DROPPED"
  echo "Calculating average for JITTER..."
  calculate_average "jitter" ".jit" 1 12
  echo "Calculating average for ATRASO..."
  calculate_average "atraso" ".del" 1 12
  echo "Calculating average for VAZAO..."
  calculate_average "vazao"  ".vaz" 1 12
  cd ..
}

BEGIN=$1
END=$2

for i in $(seq $BEGIN $END); do
  SEED=$i

#  echo "Simulating OLSR with seed $SEED..."
#  simulate_protocol $SEED "olsr"
#  echo "Simulating OLSR-ETX with seed $SEED..."
#  simulate_protocol $SEED "olsr-etx"
#  echo "Simulating OLSR-ML with seed $SEED..."
#  simulate_protocol $SEED "olsr-ml"
  echo "Simulating OLSR-LD with seed $SEED..."
  simulate_protocol $SEED "olsr-ld"
done
