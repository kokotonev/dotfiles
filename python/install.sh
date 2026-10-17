#!/bin/sh
#
# Python
#
# Installs uv if it's missing, then Python with uv. Pinned to a minor version, so you always know which
# one you get, while uv still picks the latest patch release of it. `--default` also adds `python` and
# `python3` executables to ~/.local/bin (put on PATH by python/path.sh).

PYTHON_VERSION=3.14

# The standalone uv lives in ~/.local/bin too. On a first bootstrap the shell config isn't loaded yet,
# so add it to PATH here as well.
export PATH="$HOME/.local/bin:$PATH"

# On macOS uv comes from the Brewfile. Elsewhere (Linux), install it with uv's official installer.
# UV_NO_MODIFY_PATH stops the installer from adding lines to ~/.bashrc and friends: they're symlinks
# into this repo, and python/path.sh already puts ~/.local/bin on PATH.
if ! command -v uv >/dev/null 2>&1
then
  echo "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi

if ! command -v uv >/dev/null 2>&1
then
  echo "uv isn't installed, skipping Python"
  exit 0
fi

# Keep a standalone uv up to date. A Homebrew uv is updated by `brew upgrade` instead, and can't self-update.
if [ "$(command -v uv)" = "$HOME/.local/bin/uv" ]
then
  uv self update
fi

# `--default` is a uv preview feature; naming it in --preview-features stops uv from warning about that on every run
uv python install "$PYTHON_VERSION" --default --preview-features python-install-default
