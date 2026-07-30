# powerlevel10k instant prompt -- must stay at the very top, before anything
# that could produce output.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="default"

# zsh-syntax-highlighting has to come last -- it wraps the widgets every plugin
# before it defines.
plugins=(
    git
    zsh-autosuggestions
    fzf-zsh-plugin
    zsh-syntax-highlighting
)

# Must be set before oh-my-zsh loads: fzf-zsh-plugin only installs its own
# defaults when this is empty.
export FZF_DEFAULT_OPTS="
        --ansi
        --tmux=center,50%
        --pointer=' '
        --prompt='  '
        --info=hidden
        --layout=reverse"

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

################################################################
############################ ENV ###############################
################################################################

export XDG_CONFIG_HOME="$HOME/.config"

export OMARCHY_PATH="$HOME/.local/share/omarchy"
export BAT_THEME=ansi

typeset -U path
path=("$OMARCHY_PATH/bin" "$HOME/.local/bin" $path)
command -v go >/dev/null 2>&1 && path+=("$(go env GOPATH)/bin")
export PATH

# man page colors -- annotated by dave eddy (@yousuckatprogramming)
# explained - https://youtu.be/D0sG2fj0G4Y
# borrowed heavily from https://grml.org

# Begin blinking text mode
# I just use bold red here since my terminal has blinking disabled
export LESS_TERMCAP_mb=$'\e[1;31m'

# Begin bold text mode
export LESS_TERMCAP_md=$'\e[1;31m'

# End all special formatting started by mb/md/etc.
export LESS_TERMCAP_me=$'\e[0m'

# End standout mode
export LESS_TERMCAP_se=$'\e[0m'

# Begin standout mode
# search results - bold, yellow foreground, blue background.
export LESS_TERMCAP_so=$'\e[1;33;44m'

# End underline mode
export LESS_TERMCAP_ue=$'\e[0m'

# Begin underline mode
# underline and bold green
export LESS_TERMCAP_us=$'\e[4;1;32m'

# Begin reverse-video mode
export LESS_TERMCAP_mr=$'\e[7m'

# Begin dim/half-bright mode
export LESS_TERMCAP_mh=$'\e[2m'

# Begin subscript mode
# (probably isn't supported)
export LESS_TERMCAP_ZN=$'\e[74m'

# End subscript mode
# (probably isn't supported)
export LESS_TERMCAP_ZV=$'\e[75m'

# Begin superscript mode
# (probably isn't supported)
export LESS_TERMCAP_ZO=$'\e[73m'

# End superscript mode
# (probably isn't supported)
export LESS_TERMCAP_ZW=$'\e[75m'

# Finally wire up man to use less
# this is usually the default but let's just be sure
export MANPAGER='less'

################################################################
########################## HISTORY #############################
################################################################

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt histignorespace
setopt share_history extended_history hist_ignore_dups hist_reduce_blanks

################################################################
########################### ALIAS ##############################
################################################################

alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

alias n="nvim"
alias opencode="OPENCODE_ENABLE_EXA=1 opencode"
alias http="openapi-to-http"
alias ld='lazydocker'
alias get_idf='. $HOME/esp/esp-idf/export.sh'

theme-switcher() {
  local theme
  theme=$(omarchy-theme-list | fzf --prompt='theme> ') || return
  [[ -n $theme ]] && omarchy-theme-set "$theme"
}

################################################################
########################### TOOLS ##############################
################################################################

command -v mise   >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v pyenv  >/dev/null 2>&1 && eval "$(pyenv init --path)"

[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

################################################################
######################### KEYBINDINGS ##########################
################################################################

# Ctrl-S is XOFF at the terminal level until flow control is off.
unsetopt flow_control

bindkey '\t\t' autosuggest-accept

bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^s "ssh-fzf\n"
bindkey -s ^g "lazygit\n"
bindkey -s ^t "theme-switcher\n"
