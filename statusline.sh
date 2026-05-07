#!/bin/bash
# Read all of stdin into a variable
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~" | split("/") | .[-2:]  | join("/")')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

BOLD='\033[1m'; RESET='\033[0m'
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

COST_FMT=$(printf '$%.2f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

USED_TOKENS=$((CTX_SIZE * PCT / 100))
USED_TOKENS_K=$((USED_TOKENS / 1000))
CTX_SIZE_K=$((CTX_SIZE / 1000))

printf "${BOLD}${CYAN}%s${RESET} 📁 %s 📜 ${BAR_COLOR}%s${RESET} %s%% (%sK/%sK) 💰 ${YELLOW}%s${RESET} ⏱️ ${GREEN}%sm %ss${RESET}\n" \
    "$MODEL" "$DIR" "$BAR" "$PCT" "$USED_TOKENS_K" "$CTX_SIZE_K" "$COST_FMT" "$MINS" "$SECS"