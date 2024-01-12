#!/bin/bash


current_tty=$(tmux display-message -p '#{pane_tty}')
is_vim="ps -o state= -o comm= -t "$current_tty" \
  | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(fzf|view|n?vim?x?)(diff)?$'"


if eval $is_vim; then
  current_path="$(ps -u -t "$current_tty" | grep -Eo 'n?vim .*' | cut -d' ' -f2 | xargs dirname)"
  tmux split-window -"$1" -c "$current_path"
else
  tmux split-window -"$1" -c '#{pane_current_path}'
fi

