#!/bin/bash

# scripts to run fuzz campaigns under different setting
# usage: 
# /path/to/f.sh "command" [input_path]
AFL_FUZZ="afl-fuzz"
CMD=$1
IN=${2:-"in"}
EXE=$(echo "$CMD" | awk '{print $1}' | awk -F'/' '{print $NF}')
NAME=${FUZZ:-$EXE}

# export AFL_IGNORE_PROBLEMS=1

labels="default|fast|fastllm|llm|fastllmsum|fastllmavg|llmsum|llmavg"
IFS='|' read -ra label_array <<< "$labels"

for label in "${label_array[@]}"; do
  sched=$label
  unset AFL_LLM_FAVOR

  if [[ $sched == *sum ]]; then
    export AFL_LLM_FAVOR=SUM
    sched=${sched%sum}
  fi

  if [[ $sched == *avg ]]; then
    export AFL_LLM_FAVOR=AVG
    sched=${sched%avg}
  fi

  $AFL_FUZZ -p $sched -i $IN -o out_${NAME}_${label} -- $CMD &
done

counter=0
# Run plot.sh every 2 hours
while true; do
  sleep 2h
  ((counter+=2))
  # Run plot.sh with the appropriate arguments
  ./plot.sh $NAME ${NAME}_${counter}h.pdf
done
