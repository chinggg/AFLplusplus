#!/bin/bash

# scripts to run fuzz campaigns under different setting
# usage: 
# /path/to/f.sh "command" [input_path]
AFL_FUZZ="afl-fuzz -s 42"
CMD=$1
IN=${2:-"in"}
EXE=$(echo "$CMD" | awk '{print $1}' | awk -F'/' '{print $NF}')
NAME=${FUZZ:-$EXE}

# export AFL_IGNORE_PROBLEMS=1

labels="default|fast|fastllm|fastllmsum|llm|llmsum|llmX2|llmX4|llmsumX2|llmsumX4"
IFS='|' read -ra label_array <<< "$labels"

for label in "${label_array[@]}"; do
  sched=$label
  unset AFL_LLM_FACTOR
  unset AFL_LLM_MODE
  if [[ $label =~ X([0-9]+)$ ]]; then
    export AFL_LLM_FACTOR=${BASH_REMATCH[1]}
    sched=${sched%X[0-9]}
  fi

  if [[ $sched == *sum ]]; then
    export AFL_LLM_MODE=SUM
    sched=${sched%sum}
  fi

  $AFL_FUZZ -p $sched -i $IN -o out_${NAME}_${label} -- $CMD &
done

counter=0
# Run plot.sh every 2 hours
while true; do
  sleep 2h
  ((counter+=2))
  # Run plot.sh with the appropriate arguments
  ./plot.sh $NAME ${NAME}_${counter}h.png
done
