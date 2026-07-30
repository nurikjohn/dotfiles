#!/usr/bin/env bash
# Install package dependencies and symlink the dotfiles into $HOME.
# Idempotent: safe to re-run after pulling changes.
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

STOW_PACKAGES=(zsh utils ghostty tmux nvim opencode hypr)

NVIM_REPO="https://github.com/nurikjohn/config.nvim"

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# oh-my-zsh only resolves plugins and themes out of $ZSH_CUSTOM, so these are
# cloned rather than installed from the AUR.
OMZ_REPOS=(
  "plugins/zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
  "plugins/zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
  "plugins/fzf-zsh-plugin|https://github.com/unixorn/fzf-zsh-plugin"
)

# Strip comments and blank lines from a package list.
read_packages() {
  [[ -f $1 ]] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -- "$1" | grep -v '^$' || true
}

install_pacman() {
  local pkgs
  mapfile -t pkgs < <(read_packages packages/pacman.txt)
  ((${#pkgs[@]})) || return 0
  echo "==> pacman: ${pkgs[*]}"
  sudo pacman -S --needed --noconfirm -- "${pkgs[@]}"
}

install_aur() {
  local pkgs helper
  mapfile -t pkgs < <(read_packages packages/aur.txt)
  ((${#pkgs[@]})) || return 0

  helper=""
  for h in yay paru; do
    if command -v "$h" >/dev/null 2>&1; then helper=$h; break; fi
  done
  if [[ -z $helper ]]; then
    echo "!! no AUR helper (yay/paru) found; skipping: ${pkgs[*]}" >&2
    return 0
  fi

  echo "==> $helper: ${pkgs[*]}"
  "$helper" -S --needed --noconfirm -- "${pkgs[@]}"
}

install_omz() {
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "==> installing oh-my-zsh"
    # KEEP_ZSHRC stops the installer replacing the stowed .zshrc with its
    # template; RUNZSH stops it dropping us into an interactive shell.
    RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  local entry dest url
  for entry in "${OMZ_REPOS[@]}"; do
    dest="$ZSH_CUSTOM_DIR/${entry%%|*}"
    url="${entry#*|}"
    if [[ -d $dest/.git ]]; then
      echo "==> updating ${entry%%|*}"
      git -C "$dest" pull --quiet --ff-only || echo "!! could not update $dest" >&2
    else
      echo "==> cloning ${entry%%|*}"
      git clone --depth=1 --quiet "$url" "$dest"
    fi
  done

}

install_nvim() {
  local dest="$HOME/.config/nvim"

  if [[ -d $dest/.git ]]; then
    echo "==> updating config.nvim"
    git -C "$dest" pull --quiet --ff-only || echo "!! could not update $dest" >&2
    return 0
  fi

  if [[ -e $dest ]]; then
    echo "!! $dest exists but is not a git checkout; leaving it alone" >&2
    return 0
  fi

  echo "==> cloning config.nvim"
  git clone --quiet "$NVIM_REPO" "$dest"
}

# Omarchy seeds ~/.config/hypr/*.conf and opencode writes its own opencode.json,
# both of which block stow. Move any such plain file aside so the repo copy can
# be linked; the originals are Omarchy/opencode defaults, kept as .bak.
clear_stow_blockers() {
  local f
  for f in \
    "$HOME/.config/opencode/opencode.json" \
    "$HOME/.config/hypr/bindings.conf" \
    "$HOME/.config/hypr/input.conf" \
    "$HOME/.config/hypr/monitors.conf" \
    "$HOME/.config/hypr/hyprlock.conf"; do
    if [[ -f $f && ! -L $f ]]; then
      echo "==> moving pre-existing $f aside"
      mv -- "$f" "$f.pre-stow.bak"
    fi
  done
}

link_dotfiles() {
  if ! command -v stow >/dev/null 2>&1; then
    echo "!! stow is not installed; cannot link dotfiles" >&2
    return 1
  fi
  clear_stow_blockers
  echo "==> stow: ${STOW_PACKAGES[*]}"
  stow --restow --verbose --target="$HOME" -- "${STOW_PACKAGES[@]}"
}

# ~/.config/ghostty/config belongs to Omarchy -- `omarchy font set` rewrites its
# font-family line with `sed -i`, which replaces a symlink with a regular file.
# So it is not stowed; instead the stowed local.conf is pulled in from it.
link_ghostty_include() {
  local cfg="$HOME/.config/ghostty/config"
  local include='config-file = ?"~/.config/ghostty/local.conf"'

  [[ -f $cfg ]] || { echo "!! $cfg not found; skipping ghostty include" >&2; return 0; }
  if grep -qF 'ghostty/local.conf' "$cfg"; then
    echo "==> ghostty include already present"
    return 0
  fi

  echo "==> adding ghostty include to $cfg"
  printf '\n# Personal overrides (dotfiles repo)\n%s\n' "$include" >>"$cfg"
}

# Same idea for tmux: Omarchy's tmux.conf owns the status bar and its theming,
# so it is left alone and the stowed local.conf is sourced from the end of it.
link_tmux_include() {
  local cfg="$HOME/.config/tmux/tmux.conf"
  local include='source-file -q ~/.config/tmux/local.conf'

  [[ -f $cfg ]] || { echo "!! $cfg not found; skipping tmux include" >&2; return 0; }
  if grep -qF 'tmux/local.conf' "$cfg"; then
    echo "==> tmux include already present"
    return 0
  fi

  echo "==> adding tmux include to $cfg"
  printf '\n# Personal overrides (dotfiles repo)\n%s\n' "$include" >>"$cfg"
}

if [[ ${1-} == "--link-only" ]]; then
  link_dotfiles
  link_ghostty_include
  link_tmux_include
else
  install_pacman
  install_aur
  install_omz
  install_nvim
  link_dotfiles
  link_ghostty_include
  link_tmux_include
fi

echo "==> done."
echo "    Set zsh as your login shell with: chsh -s /usr/bin/zsh"
