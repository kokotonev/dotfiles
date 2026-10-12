# Load zsh's color variables
autoload colors && colors

# Find git binary or default to /usr/bin/git if not found. This is used in the prompt to show the current git branch.
if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

# Function to get current git branch
parse_git_branch() {
  local branch
  branch=$(git branch --show-current 2> /dev/null)
  if [ -n "$branch" ]; then
    echo "%{$fg_bold[white]%}[$branch]%{$reset_color%} "
  fi
}

# Shows how many local commits are not yet pushed to the branch's upstream.
# Prints nothing outside a repo, on a branch without an upstream, or in detached HEAD.
need_push () {
  local number
  number=$($git rev-list --count '@{upstream}..HEAD' 2>/dev/null) || return

  if (( number > 0 ))
  then
    echo "%{$fg_bold[magenta]%}($number unpushed)%{$reset_color%} "
  fi
}

# Prompt segments
prompt_user='%F{202}%n%f'
prompt_dir='%F{214}%d%f'

# Prompt customization
PROMPT='${prompt_user} ~ ${prompt_dir} $(parse_git_branch)$(need_push)# '