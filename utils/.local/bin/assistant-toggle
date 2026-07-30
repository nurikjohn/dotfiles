#!/bin/bash
set -euo pipefail

assistants=("opencode" "claude" "gemini" "codex")
DEFAULT_ASSISTANT="${DEFAULT_ASSISTANT:-opencode}"

force_select=false
if [ "${1-}" = "--select" ]; then
  force_select=true
  shift
fi

find_assistant_in_window() {
  tmux list-panes -F '#{pane_id}\t#{pane_title}\t#{pane_current_command}\t#{pane_start_command}' |
    while IFS=$'\t' read -r pid title current start; do
      to_lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
      lt=$(to_lower "$title")
      lc=$(to_lower "$current")
      ls=$(to_lower "$start")
      for a in "${assistants[@]}"; do
        la=$(to_lower "$a")
        if [[ "$lt" == *"$la"* ]] || [[ "$lc" == *"$la"* ]] || [[ "$ls" == *"$la"* ]]; then
          printf '%s\n' "$pid"
          return 0
        fi
      done
    done
}

select_assistant() {
  if [ -n "${TMUX-}" ] && command -v fzf-tmux >/dev/null 2>&1; then
    printf '%s\n' "${assistants[@]}" | fzf-tmux -p 60%,50% --prompt="select assistant > " --reverse --border
  elif command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${assistants[@]}" | fzf --prompt="select assistant > " --reverse --border
  else
    printf '%s\n' "${assistants[0]}"
  fi
}

current_pane=$(tmux display-message -p '#{pane_id}')
# If an assistant is already in this window (including current pane), focus it.
if assistant_pane=$(find_assistant_in_window); [ -n "$assistant_pane" ]; then
  if [ "$assistant_pane" != "$current_pane" ]; then
    tmux select-pane -t "$assistant_pane"
  fi
  exit 0
fi

# Otherwise, if there is a pane to the right, switch to it.
rightmost_pane=$(tmux list-panes -F '#{pane_id} #{pane_right}' | sort -k2 -rn | head -1 | cut -d' ' -f1)
if [ -n "$rightmost_pane" ] && [ "$rightmost_pane" != "$current_pane" ]; then
  tmux select-pane -t "$rightmost_pane"
  exit 0
fi

selection=""
if $force_select; then
  status=0
  set +e
  selection=$(select_assistant)
  status=$?
  set -e

  case "$status" in
    0) ;;
    130) exit 0 ;; # ESC/ctrl-c in fzf-tmux popup
    *) exit "$status" ;;
  esac

  [ -z "$selection" ] && exit 0
else
  selection="$DEFAULT_ASSISTANT"
fi

assistant_cmd=("$selection")
if [ "$#" -gt 0 ]; then
  assistant_cmd+=("$@")
fi

printf -v assistant_cmd_str "%q " "${assistant_cmd[@]}"
assistant_cmd_str="${assistant_cmd_str% }"

# Spawn new pane with the selected assistant and set its title.
tmux split-window -h -p 50 "printf '\033]2;${selection}\033\\'; exec ${assistant_cmd_str}"
