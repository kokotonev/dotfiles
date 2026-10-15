#!/bin/sh
#
# Python
#
# Installs Python with uv. Pinned to a minor version, so you always know which one you get, while
# uv still picks the latest patch release of it. `--default` also adds `python` and `python3`
# executables to ~/.local/bin (put on PATH by python/path.sh).

PYTHON_VERSION=3.14

if command -v uv >/dev/null 2>&1
then
  uv python install "$PYTHON_VERSION" --default
fi
