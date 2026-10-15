# Koko's dotfiles

These are my personal dotfiles for easily reproducing and customizing my Linux and macOS environments. 

The structure and design approach behind this repo were inspired by Zach Holman's [dotfiles repo](https://github.com/holman/dotfiles).

## Install

The repo must live at `~/.dotfiles`, because `zshrc` points `$DOTFILES` there and the symlinks point into it.

```sh
git clone https://github.com/kokotonev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/script/bootstrap
```

⚠️ NOTE: Run the script; don't `source` it. It's a bash script and breaks inside zsh.

Then open a new terminal.

`script/bootstrap` does three things:

1. **Creates your local git config.** It asks for your git author name and email and generates `git/gitconfig.local.symlink` from `git/gitconfig.local.symlink.example`. The credential helper is set to `osxkeychain` on macOS and `cache` on Linux. The generated file is gitignored, and the step is skipped if the file already exists.
2. **Links the dotfiles.** Every `<topic>/<name>.symlink` becomes a symlink at `~/.<name>`. If a file already exists there, you're asked what to do:
   - `s` / `S`: skip this file / skip all
   - `o` / `O`: overwrite this file / overwrite all
   - `b` / `B`: back up this file to `~/.<name>.backup`, then link / back up all

   Press only one of these keys. Any other key, including Enter, aborts the script. Nothing is lost if that happens; just run it again.

3. **Installs software (macOS only).** It runs `bin/dotfiles-update`, which:
   - pulls the latest dotfiles,
   - installs [Homebrew](https://brew.sh) if it's missing (asks for your password), then runs `brew update` and `brew upgrade`,
   - runs `script/install`, which installs everything in the [Brewfile](Brewfile) with `brew bundle` and then runs every `<topic>/install.sh` (e.g. `python/install.sh` installs the latest Python with uv).

   If an app from the Brewfile is already in `/Applications` but wasn't installed with Homebrew, `brew bundle` reports it as failed and moves on. To hand such an app over to Homebrew, run `brew install --cask --force <cask>` once.

You can run bootstrap again at any time. Files that already point to the right place are skipped without asking. Answering `b` again for a file replaces any existing `.backup` of it.

To update the dotfiles and all software later, run `dotfiles-update` from any terminal.

These tools aren't installed by bootstrap, but the config uses them if they're there:

| Tool | Expected location | Used by | If it's missing |
|---|---|---|---|
| [nvm](https://github.com/nvm-sh/nvm) | `~/.nvm` | `node/` | Skipped quietly |
| [Google Cloud SDK](https://cloud.google.com/sdk) | `~/Documents/google-cloud-sdk` | `gcloud/` | Skipped quietly |
| VS Code `code` command | on `$PATH` | `shell/editor.sh` (`$EDITOR`, used by git for commit messages) | `$EDITOR` falls back to `nano`. Installing the `visual-studio-code` cask provides it. |

### Python

Python is managed by [uv](https://docs.astral.sh/uv/), not Homebrew. `python` and `python3` live in `~/.local/bin`.

- `uv python install 3.13`: install another version; `uv python list`: see what's installed
- `uv init` / `uv add <package>` / `uv sync`: manage a project and its `.venv`
- `uv tool install <tool>`: install a command-line tool globally (e.g. `ruff`, `ipython`)

### PostgreSQL

The Brewfile installs `postgresql@18`. Its data lives in `/opt/homebrew/var/postgresql@18`, and your macOS user is the superuser (no password locally).

| Command | What it does |
|---|---|
| `brew services start postgresql@18` | Start the server now and on every login |
| `brew services stop postgresql@18` | Stop it and don't start it on login |
| `brew services run postgresql@18` | Start it now only, not on login |
| `brew services list` | Show whether it's running |

## How it works

Everything is grouped into topic folders (`git/`, `zsh/`, `node/`, …). The file extension says which shell a file is for:

| Extension | Use it for |
|---|---|
| `.sh` | Shared config: aliases, `PATH`, exports. Write it so it works in both zsh and bash (no `setopt`, `zstyle`, `%F{…}` and so on). |
| `.zsh` | zsh-only config |

`~/.zshrc` loads every `*.sh` and `*.zsh` file in every topic, sorted alphabetically by path, in three phases:

| File | When it's loaded | Use it for |
|---|---|---|
| `<topic>/path.sh` or `path.zsh` | First | `$PATH` and other environment setup |
| `<topic>/*.sh` or `*.zsh` | Second | Aliases, options, prompt, everything else |
| `<topic>/completion.sh` or `completion.zsh` | Last, after `compinit` | Tab completion |

`install.sh` files are skipped, since they're installers (see below), not config. Any other script that shouldn't be sourced, like `homebrew/bootstrap`, has no `.sh` extension.

A few other kinds of file have a special role:

| File | Purpose |
|---|---|
| `<topic>/*.symlink` | Linked into `~` by `script/bootstrap`. Must sit directly inside a topic folder. |
| `functions/<name>` | Autoloaded zsh function. A matching `functions/_<name>` provides its completion. |
| `~/.localrc` | Not in the repo. Sourced before any topic file. Put secrets and machine-specific environment variables here. |
| `~/.gitconfig.local` | The generated, gitignored git config. Included last, so it overrides the shared `gitconfig`. |

## Making changes

Edit files in `~/.dotfiles`. The symlinks make your home directory see the changes right away.

| Change | What to do afterwards |
|---|---|
| Edit an existing file | git uses the new value on the next command. For zsh, open a new terminal or run `exec zsh`. |
| Add a new `*.sh` or `*.zsh` file or a new topic folder | Nothing; every new shell picks it up. |
| Add a function to `functions/` | Open a new terminal. |
| Add a new `*.symlink` file | Run `script/bootstrap` again. It links only the new file. |
| Change your git name, email or credential helper | Edit `git/gitconfig.local.symlink` directly. To be asked again, delete it and re-run bootstrap. |

Then commit and push. On other machines, `git pull` in `~/.dotfiles` applies the changes.

Some installers (conda, gcloud, nvm) append lines to `~/.zshrc`. Because that file is a symlink, those lines end up in `zsh/zshrc.symlink` and show up in `git status`. Move them into a topic's `path.sh` (or `path.zsh` if they're zsh-specific), or into `~/.localrc` if they're machine-specific.

## Handy commands

- `c <project>`: jump to a folder in `~/Documents/Projects`, with tab completion
- `reload!`: re-source `~/.zshrc`
- `pubkey`: copy `~/.ssh/id_ed25519.pub` to the clipboard (or print it where there's no clipboard)
- `ll`: long listing of all files, with colours
- Git shortcuts (`gs`, `ga`, `gcm`, `glog`, …): see [git/aliases.sh](git/aliases.sh)

The prompt shows the current git branch and how many commits haven't been pushed yet.

## Credits

Portions of this repo are derived from [holman/dotfiles](https://github.com/holman/dotfiles), © Zach Holman, under the MIT License. See [licenses/holman-mit.md](licenses/holman-mit.md).
