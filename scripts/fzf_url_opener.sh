#!/bin/bash

URL=$(tmux capture-pane -J -p |
  grep -oE '(https?|ftp)://[^")'\'' >[:space:]\\]+' |
  sort -u |
  fzf -d20 --multi --bind ctrl-a:select-all,ctrl-d:deselect-all)

if [ -n "$URL" ]; then
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "$URL" | while read -r line; do
      cmd.exe /c start microsoft-edge:"$line" 2>/dev/null
    done
  else
    echo "$URL" | while read -r line; do
      xdg-open "$line" 2>/dev/null
    done
  fi
fi
