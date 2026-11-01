#!/bin/bash
# Claude Code status line: [Model · effort] | 📁 Folder | branch | ctx bar % | 5h bar % | 7d bar % | $cost
input=$(cat)

BLUE=$'\033[1;38;5;33m'   # bold true blue (#0087ff)
GREEN=$'\033[1;38;5;28m'  # bold dark green (#008700)
YELLOW=$'\033[1;38;5;220m' # bold yellow
RED=$'\033[1;91m'         # bold bright red
DIM=$'\033[90m'
RESET=$'\033[0m'
WARN=70              # % at which a value turns yellow
LIMIT=90             # % at which a value turns red
BAR_WIDTH=10         # number of cells in each progress bar

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")
branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')

sep="${DIM} | ${RESET}"

# Print "label ▓▓▓░░░░░░░ N%" colored green / yellow / red by threshold
pct() {
  local label=$1 val=$2 n color filled empty bar="" i
  n=$(printf '%.0f' "$val")
  if   [ "$n" -ge "$LIMIT" ]; then color=$RED
  elif [ "$n" -ge "$WARN" ];  then color=$YELLOW
  else                             color=$GREEN
  fi
  filled=$(( (n * BAR_WIDTH + 50) / 100 ))
  [ "$filled" -gt "$BAR_WIDTH" ] && filled=$BAR_WIDTH
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( BAR_WIDTH - filled ))
  for ((i = 0; i < filled; i++)); do bar+="▓"; done
  for ((i = 0; i < empty; i++));  do bar+="░"; done
  printf '%s%s %s %s%%%s' "$color" "$label" "$bar" "$n" "$RESET"
}

out="${BLUE}[${model}${effort:+ · ${effort}}]${RESET}${sep}${BLUE}📁 ${dir}${RESET}"
[ -n "$branch" ] && out="${out}${sep}${BLUE}${branch}${RESET}"
[ -n "$ctx" ]    && out="${out}${sep}$(pct ctx "$ctx")"
[ -n "$five" ]   && out="${out}${sep}$(pct 5h "$five")"
[ -n "$week" ]   && out="${out}${sep}$(pct 7d "$week")"
[ -n "$cost" ]   && out="${out}${sep}${BLUE}\$$(printf '%.2f' "$cost")${RESET}"

printf '%s' "$out"
