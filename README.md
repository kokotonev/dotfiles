# Koko's dotfiles

These are my personal dotfiles for easily reproducing and customizing my Linux and macOS environments. 

The structure and design approach behind this repo were inspired by Zach Holman's [dotfiles repo](https://github.com/holman/dotfiles).

## Install

The repo must live at `~/.dotfiles`, because `zshrc` and `bashrc` point `$DOTFILES` there and the symlinks point into it.

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

   Both `~/.zshrc` and `~/.bashrc` are linked on every machine; the one for a shell you don't use is simply never read. On Linux, Ubuntu's default `~/.bashrc` already exists, so expect to be asked about it. Answer `b`: the parts of it worth keeping are already in `bash/`.

3. **Installs software.** It runs `bin/dotfiles-update`, which:
   - pulls the latest dotfiles,
   - on macOS, installs [Homebrew](https://brew.sh) if it's missing (asks for your password), then runs `brew update` and `brew upgrade`,
   - runs `script/install`, which installs the system packages and then runs every `<topic>/install.sh`:
     - **macOS:** everything in the [Brewfile](Brewfile), with `brew bundle`.
     - **Linux:** the packages from the [Aptfile](Aptfile) that aren't installed yet, with `sudo apt-get`.
     - `python/install.sh` installs uv if it's missing (on Linux, from uv's official installer), then the latest Python with uv.
     - `node/install.sh` installs or updates nvm, then Node.js with nvm (see [Node.js](#nodejs)).
     - `postgres/install.sh` installs PostgreSQL on Linux (see [PostgreSQL](#postgresql)).

   If an app from the Brewfile is already in `/Applications` but wasn't installed with Homebrew, `brew bundle` reports it as failed and moves on. To hand such an app over to Homebrew, run `brew install --cask --force <cask>` once.

   On Linux, `sudo` is only used when something is actually missing, so a routine `dotfiles-update` doesn't ask for your password. Without sudo rights (e.g. on a work server), the apt and PostgreSQL steps are skipped with a message and the rest still runs. `dotfiles-update` never runs `apt upgrade`: keeping system packages up to date is left to `sudo apt upgrade` and Ubuntu's automatic security updates.

You can run bootstrap again at any time. Files that already point to the right place are skipped without asking. Answering `b` again for a file replaces any existing `.backup` of it.

To update the dotfiles and all software later, run `dotfiles-update` from any terminal.

The [Google Cloud SDK](https://cloud.google.com/sdk) isn't installed by bootstrap. If it's in `~/Documents/google-cloud-sdk`, `gcloud/` puts it on `PATH` and loads its completion; otherwise it's skipped quietly.

`$EDITOR`, which git uses for commit messages, is VS Code (`code --wait`) wherever the `code` command exists. On macOS, the `visual-studio-code` cask in the Brewfile provides it. On a server, it's there in VS Code's terminal when you connect with Remote SSH. Everywhere else, `$EDITOR` is `nano` (see `shell/editor.sh`).

### Python

Python is managed by [uv](https://docs.astral.sh/uv/), not Homebrew or apt. `python` and `python3` live in `~/.local/bin`. On Linux, uv itself lives there too and is updated with `uv self update` on every `dotfiles-update`; on macOS it comes from the Brewfile. The system's own `/usr/bin/python3` on Linux is left alone, since Ubuntu's tools rely on it.

- `uv python install 3.13`: install another version; `uv python list`: see what's installed
- `uv init` / `uv add <package>` / `uv sync`: manage a project and its `.venv`
- `uv tool install <tool>`: install a command-line tool globally (e.g. `ruff`, `ipython`)

### Node.js

Node.js is managed by [nvm](https://github.com/nvm-sh/nvm), on both systems. `node/install.sh` clones nvm into `~/.nvm` and updates it to its latest release on every `dotfiles-update`. It isn't installed with Homebrew or apt: nvm doesn't support Homebrew installs, and Ubuntu doesn't package it.

The installer pins Node.js to major version 24 and makes it the default for new shells. Each update picks up the newest 24.x release and moves your global npm packages over to it. To switch to another major version, change `NODE_VERSION` in `node/install.sh`.

- `nvm ls`: see what's installed; `nvm install 22` / `nvm use 22`: install / switch the current shell to another version
- `nvm uninstall <version>`: remove an old version (updates leave the previous ones installed)
- A project's `.nvmrc` file pins its Node version; run `nvm use` in that folder to switch to it

### PostgreSQL

PostgreSQL 18 on both systems. To move to another major version, change it in both places: `postgresql@18` in the Brewfile and `PG_VERSION` in `postgres/install.sh`.

**macOS:** the Brewfile installs `postgresql@18`. Its data lives in `/opt/homebrew/var/postgresql@18`, and your macOS user is the superuser (no password locally).

| Command | What it does |
|---|---|
| `brew services start postgresql@18` | Start the server now and on every login |
| `brew services stop postgresql@18` | Stop it and don't start it on login |
| `brew services run postgresql@18` | Start it now only, not on login |
| `brew services list` | Show whether it's running |

**Linux:** `postgres/install.sh` installs `postgresql-18` from the PostgreSQL project's apt repository ([apt.postgresql.org](https://wiki.postgresql.org/wiki/Apt)), because Ubuntu's own repositories have only one, older version per release. It runs as a system service that starts at boot and only listens on localhost. Its data lives in `/var/lib/postgresql/18/main`. Like on the Mac, your Linux user is a superuser, with a database of its own name, so `psql` works without a password.

| Command | What it does |
|---|---|
| `sudo systemctl status postgresql` | Show whether it's running |
| `sudo systemctl stop postgresql` / `start postgresql` | Stop / start it |
| `sudo systemctl disable postgresql` / `enable postgresql` | Don't / do start it at boot |
| `pg_lsclusters` | List the installed versions with their port, status and data directory |

If the server already had another PostgreSQL version, version 18 is installed next to it, on the next free port (usually 5433). `pg_lsclusters` shows which is which.

### Linux notes

- **`~/.profile`** stays as Ubuntu made it. It's what SSH logins read, and it loads `~/.bashrc`. Don't create a `~/.bash_profile`: bash would read that one instead and skip `~/.profile`.

## How it works

Everything is grouped into topic folders (`git/`, `zsh/`, `bash/`, `node/`, …). The shell is zsh on macOS and bash on Linux, and the file extension says which shell a file is for:

| Extension | Use it for |
|---|---|
| `.sh` | Shared config: aliases, `PATH`, exports. Write it so it works in both zsh and bash (no `setopt`, `zstyle`, `shopt`, `%F{…}` and so on). |
| `.zsh` | zsh-only config |
| `.bash` | bash-only config, mainly for Linux. Keep it working with bash 3.2+ |

`~/.zshrc` loads every `*.sh` and `*.zsh` file in every topic, and `~/.bashrc` every `*.sh` and `*.bash` file. Both sort them alphabetically by path and load them in three phases:

| File | When it's loaded | Use it for |
|---|---|---|
| `<topic>/path.*` | First | `$PATH` and other environment setup |
| `<topic>/*.*` | Second | Aliases, options, prompt, everything else |
| `<topic>/completion.*` | Last, after `compinit` (zsh) or bash-completion (bash) | Tab completion |

Some topics have a file for each shell where the shells need different code: e.g. `python/completion.zsh` and `python/completion.bash`, or `zsh/prompt.zsh` and `bash/prompt.bash`, which draw the same prompt.

`install.sh` files are skipped, since they're installers (see below), not config. Any other script that shouldn't be sourced, like `homebrew/bootstrap`, has no `.sh` extension.

A few other kinds of file have a special role:

| File | Purpose |
|---|---|
| `<topic>/*.symlink` | Linked into `~` by `script/bootstrap`. Must sit directly inside a topic folder. |
| `functions/<name>` | Autoloaded zsh function. A matching `functions/_<name>` provides its completion. bash has no autoloading, so a bash version goes in a `.bash` file (e.g. `bash/c.bash`). |
| `~/.localrc` | Not in the repo. Sourced before any topic file. Put secrets and machine-specific environment variables here. |
| `~/.gitconfig.local` | The generated, gitignored git config. Included last, so it overrides the shared `gitconfig`. |

## Making changes

Edit files in `~/.dotfiles`. The symlinks make your home directory see the changes right away.

| Change | What to do afterwards |
|---|---|
| Edit an existing file | git uses the new value on the next command. For the shell, open a new terminal or run `exec zsh` / `exec bash`. |
| Add a new `*.sh`, `*.zsh` or `*.bash` file or a new topic folder | Nothing; every new shell picks it up. |
| Add a function to `functions/` | Open a new terminal. |
| Add a new `*.symlink` file | Run `script/bootstrap` again. It links only the new file. |
| Change your git name, email or credential helper | Edit `git/gitconfig.local.symlink` directly. To be asked again, delete it and re-run bootstrap. |

Then commit and push. On other machines, `git pull` in `~/.dotfiles` applies the changes.

Some installers (conda, gcloud, nvm) append lines to `~/.zshrc` or `~/.bashrc`. Because those files are symlinks, the lines end up in `zsh/zshrc.symlink` or `bash/bashrc.symlink` and show up in `git status`. Move them into a topic's `path.sh` (or `path.zsh` if they're zsh-specific), or into `~/.localrc` if they're machine-specific.

## Handy commands

- `c <project>`: jump to a folder in `~/Documents/Projects`, with tab completion
- `reload!`: re-source `~/.zshrc` (zsh) or start a fresh bash (bash)
- `pubkey`: copy `~/.ssh/id_ed25519.pub` to the clipboard (or print it where there's no clipboard)
- `ll`: long listing of all files, with colours
- Git shortcuts (`gs`, `ga`, `gcm`, `glog`, …): see [git/aliases.sh](git/aliases.sh)

The prompt shows the current git branch and how many commits haven't been pushed yet.

## Credits

Portions of this repo are derived from [holman/dotfiles](https://github.com/holman/dotfiles), © Zach Holman, under the MIT License. See [licenses/holman-mit.md](licenses/holman-mit.md).
