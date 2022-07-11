#!/bin/bash
# Have a nice day

# USAGE examples: 
  # CLI with env vars: MINER_ADDRESS=aleoABCD...  ./run-miner.sh
  # CLI with prompts for vars:  ./run-miner.sh


# if env var MINER_ADDRESS is not set, prompt for it
if [ -z "${MINER_ADDRESS}" ]
then
  read -r -p "Enter your miner address: "
  MINER_ADDRESS=$REPLY
fi

if [ "${MINER_ADDRESS}" == "" ]
then
  MINER_ADDRESS="aleo1d5hg2z3ma00382pngntdp68e74zv54jdxy249qhaujhks9c72yrs33ddah"
fi

COMMAND="cargo run --release -- --miner ${MINER_ADDRESS} --gpu 1 --trial --verbosity 2"

for word in $*;
do
  COMMAND="${COMMAND} ${word}"
done

function exit_node()
{
    echo "Exiting..."
    kill $!
    exit
}

trap exit_node SIGINT

echo "Running miner node..."
$COMMAND &

while :
do
  echo "Checking for updates..."
  git stash
  rm Cargo.lock
  STATUS=$(git pull)

  if [ "$STATUS" != "Already up to date." ]; then
    echo "Updated code found, rebuilding and relaunching miner"
    cargo clean
    kill -INT $!; sleep 2; $COMMAND &
  fi

  sleep 1800;
done
