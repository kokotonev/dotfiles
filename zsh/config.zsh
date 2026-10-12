# The LSCOLORS variable is a string of 22 characters that describes the colors used to display files in the terminal. 
# Each pair of characters represents a file type and its corresponding color. 
# The first character in each pair represents the foreground color, while the second character represents the background color. x is the default color.
# 
# Format: Pair - Applies to - Result
# ex - directory - blue
# fx - symlink - magenta
# cx - socket - green
# dx - pipe - brown/yellow
# bx - executable - red
# eg - block device - blue on cyan
# ed - char device - blue on brown
# ab - setuid file -	black on red
# ag - setgid file -	black on cyan
# ac - dir writable by others, sticky bit -	black on green
# ad - dir writable by others, no sticky bit -	black on brown
export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

fpath=($ZSH/functions $fpath)

# lazy-load our functions (fpath is set up in fpath.zsh)
autoload -U $ZSH/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY # show !! / !$ expansions before running them
setopt EXTENDED_HISTORY # add timestamps to history
setopt HIST_IGNORE_SPACE

setopt PROMPT_SUBST # needed by prompt.zsh
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt NO_LIST_BEEP


bindkey '^[^[[D' backward-word       # Option + left arrow
bindkey '^[^[[C' forward-word        # Option + right arrow
bindkey '^[[H' beginning-of-line     # home key (or fn + left)
bindkey '^[[F' end-of-line           # end key (or fn + right)
bindkey '^[[3~' delete-char          # Delete key (or fn + backspace)
