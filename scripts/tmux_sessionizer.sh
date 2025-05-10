#!/usr/bin/env bash

switch_to() {
  if [[ -z $TMUX ]]; then
    tmux attach-session -t "$1"
  else
    tmux switch-client -t "$1"
  fi
}

has_session() {
  tmux list-sessions | grep -q "^$1:"
}

hydrate() {
  if [ -f "$2/.tmux-sessionizer" ]; then
    tmux send-keys -t "$1" "source $2/.tmux-sessionizer" c-M
  elif [ -f "$HOME/.tmux-sessionizer" ]; then
    tmux send-keys -t "$1" "source $HOME/.tmux-sessionizer" c-M
  fi
}



if [[ $# -eq 1 ]]; then
  selected=$1
else
  PATH_FILE="$HOME/paths"
  if [ ! -f "$PATH_FILE" ]; then
    cat <<EOF > "$PATH_FILE"
$HOME/ssd
$HOME/.config
$HOME/.config/scripts
EOF
  fi
  mapfile -t paths < "$PATH_FILE"
  selected=$(find "${paths[@]}" -maxdepth 1 -type d 2>/dev/null | sort -u | fzf)
fi

if [ -z "$selected" ]; then
  exit 1
fi

tmux_running=$(pgrep tmux)
selected_name=$(basename "$selected" | tr . _)

echo "$selected_name"
echo "$selected"

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -ds "$selected_name" -c "$selected"
  hydrate "$selected_name" "$selected"
fi

if ! has_session "$selected_name"; then
  tmux new-session -ds "$selected_name" -c "$selected"
  hydrate "$selected_name" "$selected"
fi

switch_to "$selected_name"
