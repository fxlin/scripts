#!/system/bin/bash
# from http://colby.id.au/node/39

echo "USER    NICE    SYS   IDLE   IOWAIT  IRQ  SOFTIRQ  STEAL  GUEST"

#while :; do
for i in {1..120} 
do
  read -a CPU </proc/stat
  if [[ ${#CPU[*]} -lt 5 && "${CPU[0]}" != "cpu" ]]; then
    echo "unexpected /proc/stat format: <${CPU[*]}>"
    exit 1
  fi
  unset CPU[0]
  CPU=("${CPU[@]}")
  TOTAL=0
  for t in "${CPU[@]}"; do ((TOTAL+=t)); done
  ((DIFF_TOTAL=$TOTAL-${PREV_TOTAL:-0}))
  for i in ${!CPU[*]}; do
    OUT_INT=$((1000*(${CPU[$i]}-${PREV_STAT[$i]:-0})/DIFF_TOTAL))
    OUT[$((i*2))]=$((OUT_INT/10))
    OUT[$((i*2+1))]=$((OUT_INT%10))
  done
  #printf '%3d.%1d%% ' "${OUT[@]}"; printf "\r"
  printf '%3d.%1d ' "${OUT[@]}"; printf "\n"
  PREV_STAT=("${CPU[@]}")
  PREV_TOTAL="$TOTAL"
  sleep 1
done
