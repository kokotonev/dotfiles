# bash counterparts of the settings in zsh/config.zsh

HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups  # skip commands starting with a space, and don't record dupes
HISTTIMEFORMAT='%F %T '           # add timestamps to history

shopt -s histappend   # append to the history file instead of overwriting it
shopt -s histverify   # show !! / !$ expansions before running them
shopt -s cdspell      # fix small typos in `cd` arguments
shopt -s checkwinsize # keep $LINES and $COLUMNS up to date after the window is resized
set -o ignoreeof      # Ctrl+D doesn't close the shell

# Save each command to the history file right away (like zsh's INC_APPEND_HISTORY), not only on exit.
# Prepended, so whatever PROMPT_COMMAND is already set (e.g. VS Code's shell integration) keeps running.
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# Lets `less` show the contents of archives, PDFs, etc. (from Ubuntu's default .bashrc)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

bind '"\e\e[D": backward-word'      # Option + left arrow
bind '"\e\e[C": forward-word'       # Option + right arrow
bind '"\e[H": beginning-of-line'    # home key (or fn + left)
bind '"\e[F": end-of-line'          # end key (or fn + right)
bind '"\e[3~": delete-char'         # Delete key (or fn + backspace)
