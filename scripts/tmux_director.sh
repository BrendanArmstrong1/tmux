#!/bin/bash

current_tty=$(tmux display-message -p '#{pane_tty}')
current_tmux_path=$(tmux display-message -p '#{pane_current_path}')


is_vim="ps -o state= -o comm= -t $current_tty \
  | grep -iqE '^[^TXZ ]+ +(\S+/)?g?(n?vim?x?)(diff)?$'"
is_lf="ps -o state= -o comm= -t $current_tty \
  | grep -iqE '^[^TXZ ]+ +(\S+/)?g?(lf)(diff)?$'"

if eval "$is_vim"; then
  full_file_path="$(ps -u -t "$current_tty" | grep -Eo 'n?vim .*' | cut -d' ' -f2)"
  current_path="$(dirname "$full_file_path")"
  if [ "$current_path" = "." ]; then
    tmux split-window -"$1" -c "$current_tmux_path"
    exit
  fi
  tmux split-window -"$1" -c "$current_path"
elif eval "$is_lf"; then
  pid=$(ps -o comm= -o pid= -t "$current_tty" | awk '/lf[^ubcd]/ {print $2}')
  current_path=$(lf -remote "query $pid jumps" | awk '/>/ {print $NF}')
  tmux split-window -"$1" -c "$current_path"
else
  tmux split-window -"$1" -c '#{pane_current_path}'
fi
