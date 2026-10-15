# Default editor for git commits, crontab -e, etc.
# VS Code if its `code` command is available (including VS Code's terminal over Remote SSH), nano otherwise.
# Not in a path file, because `code` must already be on PATH when this runs.
if command -v code >/dev/null 2>&1
then
  export EDITOR='code --wait'
else
  export EDITOR='nano'
fi
