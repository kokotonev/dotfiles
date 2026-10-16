# Like zsh/prompt.zsh, plus the host, so you can tell machines apart over SSH: user@host ~ /full/path [branch] (n unpushed) #
#
# PS1 itself never changes. Before each prompt, __dotfiles_prompt puts the git part in a variable that PS1
# refers to. Expanded variable values aren't parsed again, so a branch named e.g. `$(rm -rf ~)` is shown,
# not run. The colour codes in that variable are wrapped in \001 and \002 (what \[ and \] in PS1 turn into),
# so bash doesn't count them towards the prompt width.

__dotfiles_prompt () {
  local branch number
  __prompt_git=''

  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null)
  if [[ -n $branch ]]
  then
    __prompt_git+=$'\001\e[1;37m\002'"[$branch]"$'\001\e[0m\002 '
  fi

  # Local commits not yet pushed to the branch's upstream. Nothing outside a repo, without an upstream, or in detached HEAD.
  number=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
  if (( number > 0 ))
  then
    __prompt_git+=$'\001\e[1;35m\002'"($number unpushed)"$'\001\e[0m\002 '
  fi
}

# Prepended, so whatever PROMPT_COMMAND is already set (e.g. VS Code's shell integration) keeps running
PROMPT_COMMAND="__dotfiles_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# 38;5;202 and 38;5;214 are the same 256-colour oranges as %F{202} and %F{214} in zsh
PS1='\[\e[38;5;202m\]\u@\h\[\e[0m\] ~ \[\e[38;5;214m\]${PWD}\[\e[0m\] ${__prompt_git}# '

# In terminal emulators, also set the window/tab title to user@host: dir (like Ubuntu's default .bashrc does)
case "$TERM" in
  xterm*|rxvt*) PS1='\[\e]0;\u@\h: \w\a\]'"$PS1" ;;
esac
