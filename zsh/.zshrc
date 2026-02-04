if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="default"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf-zsh-plugin
)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:/Users/nurik/Library/Android/sdk/platform-tools/"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

export PATH="$PATH:$HOME/.rvm/bin"

################################################################
########################### ALIAS ##############################
################################################################

alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree"
alias cat="bat"

alias n="nvim"
alias http="openapi-to-http"
alias ld='lazydocker'
alias get_idf='. $HOME/esp/esp-idf/export.sh'

setopt histignorespace

[ -s "/Users/nurik/.bun/_bun" ] && source "/Users/nurik/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export DENO_INSTALL="/Users/nurik/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH=$PATH:$HOME/.local/bin/

bindkey '\t\t' autosuggest-accept

bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^s "ssh-fzf\n"
bindkey -s ^g "lazygit\n"
bindkey -s ^t "theme-switcher\n"

PATH=~/.console-ninja/.bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"

eval "$(pyenv init --path)"

. "$HOME/.local/bin/env"

export CLOUDSDK_PYTHON=/opt/homebrew/bin/python3

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux new-session -A -s home
fi
