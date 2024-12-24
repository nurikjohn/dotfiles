
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="ultima"

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

alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"

alias home="cd $HOME"

alias projects="cd $HOME/Documents/code/projects"

alias lab="cd $HOME/Documents/code/lab"
alias leetcode="cd $HOME/Documents/learning/leetcode"
alias downloads="cd $HOME/Downloads"

alias n="nvim"
alias c="clear"

setopt histignorespace

# bun completions
[ -s "/Users/nurik/.bun/_bun" ] && source "/Users/nurik/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export DENO_INSTALL="/Users/nurik/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH=$PATH:$HOME/.local/bin/

bindkey '\t\t' autosuggest-accept

bindkey -s ^f " tmux-sessionizer\n"

test -e /Users/nurik/.iterm2_shell_integration.zsh && source /Users/nurik/.iterm2_shell_integration.zsh || true

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nurik/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nurik/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nurik/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nurik/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
