# dotfiles

Personal macOS dotfiles for zsh, [Ghostty](https://ghostty.org), git, and Homebrew. One installer wires everything up via symlinks, so the repo is the source of truth — edit a tracked file and the change is live in new shells.

## Requirements

- macOS
- [Homebrew](https://brew.sh)

The installer refuses to run on anything else.

## Install

```sh
git clone <this-repo> ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh
```

`install.sh` is idempotent — re-running it is safe and only acts on what's missing or out of date. Existing real files at any target path get backed up to `<path>.bak.<epoch>` before being replaced with a symlink.

## What gets installed

| Component | Source in repo | Symlinked to |
| --- | --- | --- |
| zsh main config | `zsh/.zshrc` | `~/.zshrc` |
| zsh aliases | `zsh/aliases.sh` | `~/.config/zsh/aliases.sh` |
| Ghostty config | `ghostty/config` | `~/.config/ghostty/config` |
| git config (generic) | `git/config` | `~/.config/git/config` |
| git global ignore | `git/ignore` | `~/.config/git/ignore` |
| Homebrew packages | `homebrew/Brewfile` | (installed via `brew bundle`) |

Plus:

- [Oh My Zsh](https://ohmyz.sh) is installed if missing.
- The `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `zsh-completions` plugins are cloned into `$ZSH_CUSTOM/plugins/` and `git pull`'d on re-run.
- An ed25519 SSH key is generated at `~/.ssh/id_ed25519` if one doesn't already exist (interactive passphrase prompt).

## Git identity — bootstrap step

`git/config` is **generic** (no name, no email, no signing key) so it's safe to make this repo public. Identity lives in two **untracked** files that the installer creates as stubs the first time it runs:

- `~/.config/git/identity` — default identity used everywhere unless overridden. Contains your `[user]` block plus signing setup.
- `~/.config/git/identity.personal` — overrides the email for repos under `~/Developer/personal/` and for the dotfiles repo itself (`~/Developer/dotfiles/`).

After the first install, edit those files with your real values. The installer **never overwrites them** on subsequent runs.

```sh
$EDITOR ~/.config/git/identity            # set name, email, optionally tweak signing
$EDITOR ~/.config/git/identity.personal   # set personal email for personal/dotfiles repos
./install.sh                              # second run populates ~/.config/git/allowed_signers
```

The `allowed_signers` file binds your email to your SSH public key so locally-verified signatures show as `Good "git" signature`. It's regenerated each install run from whatever email is currently in your identity file.

To get the green "Verified" badge on GitHub, upload `~/.ssh/id_ed25519.pub` at <https://github.com/settings/keys> as **both** an authentication and a signing key.

### Adding more identity scopes

Need a third identity (e.g. a client repo)? Add another `[includeIf "gitdir:..."]` block to `git/config` pointing at a new untracked file in `~/.config/git/`.

## Local overrides

Two paths are sourced at the end of `~/.zshrc` if they exist:

- `~/.zshrc.local` — anything machine-specific.
- `~/.zshrc.work` — work-specific tweaks.

Neither is tracked. Put exports, PATH additions, and one-off aliases there instead of editing `zsh/.zshrc` directly.

## Updating

- **Add a Homebrew package:** edit `homebrew/Brewfile`, then `brew bundle --file homebrew/Brewfile` (or just re-run `./install.sh`).
- **Edit a tracked config:** save the file. Symlinks mean the change takes effect in new shells / on the next git invocation; no re-install needed.
- **Pull upstream changes:** `git pull` and re-run `./install.sh` to pick up any new symlinks or plugin updates.

## Layout

```
.
├── install.sh           # orchestrator; idempotent; uses link_file + print_* helpers
├── homebrew/Brewfile    # grouped: programming languages, tooling, apps, fonts
├── zsh/
│   ├── .zshrc           # Oh My Zsh, Ghostty integration, fzf helpers, starship init
│   └── aliases.sh       # docker / kubernetes / eza shortcuts
├── ghostty/config       # Ghostty terminal settings
├── git/
│   ├── config           # generic git config; includes identity files
│   └── ignore           # global gitignore (macOS junk, editor noise)
└── CLAUDE.md            # repo guide for AI assistants
```
