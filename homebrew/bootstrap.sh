#!/bin/sh
#
# Homebrew
#
# Installs Homebrew if it's missing. Called directly by bin/dotfiles-update; it's not
# named install.sh so script/install doesn't run it a second time.

# Adding Homebrew to PATH if it's installed, but not on PATH yet. Doing nothing if it is not installed.
. "$(dirname "$0")/path.zsh"

# Checking if Homebrew is on PATH (which would mean it is installed). If not, we install it.
if ! command -v brew >/dev/null 2>&1
then
  echo "  Installing Homebrew for you."

  # The same installer handles both macOS and Linux
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
