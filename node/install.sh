#!/usr/bin/env bash
#
# Node.js
#
# Installs nvm, or updates it to its latest release, then Node.js with nvm. Pinned to a major version, so
# you always know which one you get, while nvm still picks the latest release of it. node/path.sh loads nvm.
#
# nvm doesn't come from Homebrew or apt: nvm doesn't support Homebrew installs, and Ubuntu doesn't package it.
# It's a git clone instead, which is nvm's documented manual install and upgrade method. Not nvm's install
# script, because that one adds lines to ~/.bashrc and ~/.zshrc, which are symlinks into this repo.

NODE_VERSION=24

export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]
then
  echo "Installing nvm"
  git clone --quiet https://github.com/nvm-sh/nvm.git "$NVM_DIR"
fi

if [ -d "$NVM_DIR/.git" ]
then
  # Check out the latest release tag. Not fatal if offline: the current version keeps working.
  if git -C "$NVM_DIR" fetch --quiet --tags origin
  then
    latest_nvm=$(git -C "$NVM_DIR" describe --abbrev=0 --tags --match "v[0-9]*" "$(git -C "$NVM_DIR" rev-list --tags --max-count=1)")
    git -C "$NVM_DIR" -c advice.detachedHead=false checkout --quiet "$latest_nvm"
  fi
else
  echo "$NVM_DIR isn't a git clone, so it isn't updated"
fi

if ! [ -s "$NVM_DIR/nvm.sh" ]
then
  echo "nvm isn't installed, skipping Node.js"
  exit 0
fi

. "$NVM_DIR/nvm.sh"

installed=$(nvm version "$NODE_VERSION")      # newest installed $NODE_VERSION.x, or N/A
latest=$(nvm version-remote "$NODE_VERSION")  # newest released $NODE_VERSION.x, or N/A if offline

if [ "$installed" = N/A ]
then
  nvm install "$NODE_VERSION"
elif [ "$latest" != N/A ] && [ "$installed" != "$latest" ]
then
  # A new release: bring your global npm packages over from the previous one
  nvm install "$latest" --reinstall-packages-from="$installed"
fi

# New shells use the newest installed $NODE_VERSION.x. Older versions stay installed; `nvm uninstall <version>` removes one.
nvm alias default "$NODE_VERSION"
