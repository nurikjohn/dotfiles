# dotfiles

Personal configuration for [Omarchy](https://omarchy.org/) (Arch + Hyprland), deployed with
GNU Stow.

These configs assume a working Omarchy install. They layer on top of it rather than replacing
it — Omarchy keeps ownership of its own files, and this repo either symlinks the files it
owns outright or is *included* from Omarchy's.

## Bootstrap on a fresh machine

**1. Clone.**

The `origin` remote is SSH, which won't authenticate on a machine with no key yet. Either add
an SSH key to GitHub first, or clone over HTTPS and switch the remote later:

```bash
git clone https://github.com/nurikjohn/dotfiles ~/dotfiles
cd ~/dotfiles
```

**2. Install.**

```bash
./install.sh
```

Idempotent — safe to re-run after a pull. In order it:

1. installs `packages/pacman.txt` via pacman (needs sudo)
2. installs `packages/aur.txt` via `yay`/`paru` if one is present
3. installs oh-my-zsh, then clones `zsh-autosuggestions`, `zsh-syntax-highlighting`
   and `fzf-zsh-plugin` into `$ZSH_CUSTOM`
4. clones [config.nvim](https://github.com/nurikjohn/config.nvim) to `~/.config/nvim`
5. stows the packages below
6. appends the ghostty and tmux include lines (see *Layering* below)

`./install.sh --link-only` re-stows without touching packages.

**3. Make zsh the login shell.**

```bash
chsh -s /usr/bin/zsh
```

`install.sh` only prints this — it prompts for a password, so it can't be automated.

**4. Log out and back in. Not just a new terminal.**

`systemd --user` caches `SHELL` from login and survives a Hyprland logout, so terminals keep
launching bash even after `chsh` succeeded. A full logout (or reboot) is what fixes it.

Check with `ps -p $$ -o comm=` — **not** `echo $SHELL`, which is inherited from the session
and will keep reporting the old shell.

**5. Open nvim once.**

First launch installs plugins and compiles treesitter parsers. Give it a minute.

## What's here

| Package | Owns |
|---|---|
| `zsh` | `.zshrc`, and the prompt theme at `$ZSH_CUSTOM/themes/default.zsh-theme` |
| `hypr` | `bindings.conf`, `input.conf`, `monitors.conf`, `hyprlock.conf` |
| `tmux` | `local.conf` (bindings + status bar), `tmux-sessionizer.conf` |
| `ghostty` | `local.conf` (font size, padding, shader/link settings) |
| `nvim` | `~/.config/themes/.current/nvim.lua` — bridges the Omarchy theme into config.nvim |
| `opencode` | `opencode.json`, `prompts/` |
| `utils` | `tmux-sessionizer`, `ssh-fzf`, `assistant-toggle` in `~/.local/bin` |

Neovim itself lives in a **separate repo** cloned to `~/.config/nvim`; only the theme bridge
is here.

## Layering

Two configs are *not* stowed, deliberately:

- **`~/.config/ghostty/config`** — `omarchy font set` rewrites its `font-family` line with
  `sed -i`, which replaces a symlink with a regular file and silently detaches it from the
  repo. Omarchy keeps that file; `install.sh` appends one `config-file` line pointing at the
  stowed `local.conf`, whose values win because ghostty applies later values last.
- **`~/.config/tmux/tmux.conf`** — Omarchy owns the status bar and its theming. `install.sh`
  appends a `source-file -q` line for the stowed `local.conf`, sourced last so it overrides.

Colours everywhere use named ANSI values rather than hex, so tmux, fzf and Neovim all follow
whatever `omarchy theme set` selects. The Neovim bridge watches
`~/.config/omarchy/current` and hot-swaps the colorscheme without a restart.

## Gotchas

- **`omarchy refresh hyprland`** overwrites the hypr files this repo owns.
  **`omarchy refresh config ghostty/config`** (or `tmux/tmux.conf`) drops the appended include
  line, silently disabling those overrides. Re-run `./install.sh --link-only` to restore.
- **`lazy-lock.json` in config.nvim churns.** The active Omarchy theme decides which
  colorscheme plugin is in the spec, so the lockfile differs per machine and per theme.
- **The opencode Ollama provider** points at a Tailscale MagicDNS host. Those models stay dead
  until `tailscale` is installed and connected; it is deliberately not in
  `packages/pacman.txt`.
- **`gopls`** is installed by Mason via `go install`, so `go` must be present — it is in
  `packages/pacman.txt`.
- **Do not add `--` before the package list** in the `stow` call. GNU Stow 2.4.1 does not treat
  it as an end-of-options marker; it swallows the package names and exits 0 having linked
  nothing.
