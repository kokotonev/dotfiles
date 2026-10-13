# Loads Homebrew into the shell: sets PATH (bin and sbin), MANPATH, INFOPATH and HOMEBREW_PREFIX.
#
# Checks for a Homebrew executable in the standard locations (for macOS and Linux) and runs `brew shellenv` to add the environment variables. 
# This is useful for shells that don't automatically load Homebrew's environment, or for scripts that need to ensure Homebrew is available.

for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
do
  if [ -x "$brew_bin" ]
  then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done
unset brew_bin
