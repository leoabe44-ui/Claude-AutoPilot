#!/usr/bin/env bash
# Autopilot Stop hook: the "loop".
# Each time Claude tries to stop, this decides whether to send it back to work.
# Pure bash + sed so it runs anywhere Claude Code runs (macOS, Linux, Git Bash).
set -u

input=$(cat)
field() { printf '%s' "$input" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1; }

sid=$(field session_id)
cwd=$(field cwd)
root="${CLAUDE_PROJECT_DIR:-${cwd:-.}}"
state="$root/.autopilot/state"

[ -f "$state" ] || exit 0

get() { sed -n "s/^$1=//p" "$state" | head -1; }
put() {
  if grep -q "^$1=" "$state"; then
    sed "s|^$1=.*|$1=$2|" "$state" > "$state.tmp" && mv "$state.tmp" "$state"
  else
    printf '%s=%s\n' "$1" "$2" >> "$state"
  fi
}

[ "$(get status)" = "running" ] || exit 0

# Only the session that started the run is driven by it; other sessions in the same project stop normally.
owner=$(get session)
if [ -z "$owner" ]; then
  put session "$sid"
elif [ -n "$sid" ] && [ "$owner" != "$sid" ]; then
  exit 0
fi

iter=$(get iteration); iter=${iter:-0}
max=$(get max_iterations); max=${max:-25}
iter=$((iter + 1))

if [ "$iter" -gt "$max" ]; then
  put status paused
  printf '{"systemMessage":"Autopilot paused after %s iterations (the limit). Run /autopilot:resume to keep going."}\n' "$max"
  exit 0
fi
put iteration "$iter"

reason="Autopilot iteration $iter of $max. Do NOT stop yet. Follow the autopilot-protocol skill: read .autopilot/goal.md, .autopilot/plan.md and .autopilot/lessons.md, then run the next cycle (pick the next unchecked task, work, critique, route, retro). When the critic confirms the whole goal is met, set status=done in .autopilot/state. If you truly need the user to decide something, write the question at the top of .autopilot/plan.md, set status=needs_input in .autopilot/state, then stop."
printf '{"decision":"block","reason":"%s"}\n' "$reason"
