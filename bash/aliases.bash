# Start a fresh bash, which loads ~/.bashrc again. Unlike sourcing it, this doesn't stack old settings on top of new ones.
alias reload!='exec bash'

# Coloured output (from Ubuntu's default .bashrc). On macOS, zsh gets the same for ls through $CLICOLOR.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
