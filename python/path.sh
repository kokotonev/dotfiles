# uv's default location for the Python executables (`uv python install`) and tools (`uv tool install`).
# Prepended, so it wins over macOS's /usr/bin/python3. Also, due to the alphabetical loading of topic path files,
# it wins over Homebrew's Python.
export PATH="$HOME/.local/bin:$PATH"
