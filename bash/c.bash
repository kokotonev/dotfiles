# bash version of functions/c and functions/_c: jump into a project directory, with tab completion.
#
#   c holm<tab>/bo<tab>

c () {
  cd "$PROJECTS/$1"
}

# Completes directory names inside $PROJECTS (not the current directory), with a trailing / so you can keep going
_c () {
  local IFS=$'\n'  # one completion per line, so names with spaces stay whole
  COMPREPLY=($(cd "$PROJECTS" 2>/dev/null && compgen -d -S / -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -o nospace -F _c c
