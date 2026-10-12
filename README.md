# Koko's dotfiles

These are my personal dotfiles for easily reproducing and customizing my Linux and macOS environments. 

The structure and design approach behind this repo were inspired by Zach Holman's [dotfiles repo](https://github.com/holman/dotfiles).

## Install

The repo must live at `~/.dotfiles`, because `zshrc` points `$ZSH` there and the symlinks point into it.

```sh
git clone https://github.com/kokotonev/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/script/bootstrap
```

⚠️ NOTE: Run the script; don't `source` it. It's a bash script and breaks inside zsh.

Then open a new terminal.

`script/bootstrap` does two things:

1. **Creates your local git config.** It asks for your git author name and email and generates `git/gitconfig.local.symlink` from `git/gitconfig.local.symlink.example`. The credential helper is set to `osxkeychain` on macOS and `cache` on Linux. The generated file is gitignored, and the step is skipped if the file already exists.
2. **Links the dotfiles.** Every `<topic>/<name>.symlink` becomes a symlink at `~/.<name>`. If a file already exists there, you're asked what to do:
   - `s` / `S`: skip this file / skip all
   - `o` / `O`: overwrite this file / overwrite all
   - `b` / `B`: back up this file to `~/.<name>.backup`, then link / back up all

   Press only one of these keys. Any other key, including Enter, aborts the script. Nothing is lost if that happens; just run it again.

You can run bootstrap again at any time. Files that already point to the right place are skipped without asking. Answering `b` again for a file replaces any existing `.backup` of it.

Bootstrap does **not** install any software. The config expects these tools:

| Tool | Expected location | Used by | If it's missing |
|---|---|---|---|
| [nvm](https://github.com/nvm-sh/nvm) | `~/.nvm` | `node/` | Skipped quietly |
| [Google Cloud SDK](https://cloud.google.com/sdk) | `~/Documents/google-cloud-sdk` | `gcloud/` | Skipped quietly |
| VS Code `code` command | on `$PATH` | `git/` (commit editor) | git can't open an editor, e.g. for commits without `-m` |

## How it works

Everything is grouped into topic folders (`git/`, `zsh/`, `node/`, …). `~/.zshrc` loads every `*.zsh` file in every topic, in three phases:

| File | When it's loaded | Use it for |
|---|---|---|
| `<topic>/path.zsh` | First | `$PATH` and other environment setup |
| `<topic>/*.zsh` | Second | Aliases, options, prompt, everything else |
| `<topic>/completion.zsh` | Last, after `compinit` | Tab completion |

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
| Add a new `*.zsh` file or a new topic folder | Nothing; every new shell picks it up. |
| Add a function to `functions/` | Open a new terminal. |
| Add a new `*.symlink` file | Run `script/bootstrap` again. It links only the new file. |
| Change your git name, email or credential helper | Edit `git/gitconfig.local.symlink` directly. To be asked again, delete it and re-run bootstrap. |

Then commit and push. On other machines, `git pull` in `~/.dotfiles` applies the changes.

Some installers (conda, gcloud, nvm) append lines to `~/.zshrc`. Because that file is a symlink, those lines end up in `zsh/zshrc.symlink` and show up in `git status`. Move them into a topic's `path.zsh`, or into `~/.localrc` if they're machine-specific.

## Handy commands

- `c <project>`: jump to a folder in `~/Documents/Projects`, with tab completion
- `reload!`: re-source `~/.zshrc`
- `pubkey`: copy `~/.ssh/id_ed25519.pub` to the clipboard
- Git shortcuts (`gs`, `ga`, `gcm`, `glog`, …): see [git/aliases.zsh](git/aliases.zsh)

The prompt shows the current git branch and how many commits haven't been pushed yet.

## Credits

Portions of this repo are derived from [holman/dotfiles](https://github.com/holman/dotfiles), © Zach Holman, under the MIT License. See [licenses/holman-mit.md](licenses/holman-mit.md).
