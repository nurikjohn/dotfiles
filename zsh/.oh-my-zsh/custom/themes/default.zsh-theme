# Renders as:
#   <dir>  A › M › U › <branch>
#    ›

# COLORS =======================================================================

THEME_BRANCH_COLOR="green"
THEME_DIR_COLOR="green"
THEME_ARROW_COLOR="yellow"
THEME_GIT_STAGED_COLOR="green"
THEME_GIT_UNSTAGED_COLOR="magenta"
THEME_GIT_UNTRACKED_COLOR="blue"
THEME_GIT_HASH_COLOR="magenta"
THEME_SSH_COLOR="green"
THEME_VCS_ACTION_COLOR="black"
THEME_ARROW_SEPARATOR_COLOR="black"
THEME_COMPLETION_DESC_COLOR="green"
THEME_COMPLETION_WARNING_COLOR="yellow"
THEME_COMPLETION_ERROR_COLOR="red"
THEME_COMPLETION_MATCH_COLOR="green"

char_arrow="›"                                                  # Unicode: ›

# VCS STATUS LINE ==============================================================

export VCS="git"

vc_branch_name="%F{$THEME_BRANCH_COLOR}%b%f"
vc_action="%F{$THEME_VCS_ACTION_COLOR}%a %f%F{$THEME_ARROW_SEPARATOR_COLOR}${char_arrow}%f"
vc_unstaged_status="%F{$THEME_GIT_UNSTAGED_COLOR} M ${char_arrow}%f"
vc_git_staged_status="%F{$THEME_GIT_STAGED_COLOR} A ${char_arrow}%f"
vc_git_untracked_status="%F{$THEME_GIT_UNTRACKED_COLOR} U ${char_arrow}%f"
vc_git_hash="%F{$THEME_GIT_HASH_COLOR}%6.6i%f %F{$THEME_ARROW_SEPARATOR_COLOR}${char_arrow}%f"

if [[ -n $VCS ]]; then
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable "$VCS"
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
fi

case "$VCS" in
  "git")
    zstyle ':vcs_info:git*+set-message:*' hooks use_git_untracked
    zstyle ':vcs_info:git:*' stagedstr "$vc_git_staged_status"
    zstyle ':vcs_info:git:*' unstagedstr "$vc_unstaged_status"
    zstyle ':vcs_info:git:*' actionformats "  ${vc_action} ${vc_git_hash}%m%u%c ${vc_branch_name}"
    zstyle ':vcs_info:git:*' formats " %c%u%m ${vc_branch_name}"
    ;;
  "svn")
    zstyle ':vcs_info:svn:*' branchformat "%b"
    zstyle ':vcs_info:svn:*' formats " ${vc_branch_name}"
    ;;
  "hg")
    zstyle ':vcs_info:hg:*' branchformat "%b"
    zstyle ':vcs_info:hg:*' formats " ${vc_branch_name}"
    ;;
esac

# Show an untracked-files badge on the git status line.
+vi-use_git_untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == "true" ]] &&
    git status --porcelain | grep -m 1 "^??" &>/dev/null; then
    hook_com[misc]=$vc_git_untracked_status
  else
    hook_com[misc]=""
  fi
}

# SSH MARKER ===================================================================

ssh_marker=""
if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
  ssh_marker="%F{$THEME_SSH_COLOR}SSH%f%F{$THEME_ARROW_SEPARATOR_COLOR}:%f"
fi

# PROMPT =======================================================================

setopt PROMPT_SUBST

PROMPT="${ssh_marker} %f%F{$THEME_DIR_COLOR}%1d%f"'${vcs_info_msg_0_}'"
%F{$THEME_ARROW_COLOR} ${char_arrow}%f "

RPROMPT=""

# Registered as a hook rather than defining precmd() outright, so oh-my-zsh
# plugins that use precmd keep working.
_theme_precmd() {
  [[ -n $VCS ]] && vcs_info
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _theme_precmd

# COMPLETION ===================================================================

setopt MENU_COMPLETE

completion_descriptions="%B%F{$THEME_COMPLETION_DESC_COLOR} ${char_arrow} %f%F{$THEME_COMPLETION_MATCH_COLOR}%d%b%f"
completion_warnings="%F{$THEME_COMPLETION_WARNING_COLOR} ${char_arrow} %fno matches for %F{$THEME_COMPLETION_MATCH_COLOR}%d%f"
completion_error="%B%F{$THEME_COMPLETION_ERROR_COLOR} ${char_arrow} %f%e %d error"

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompcache"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list "m:{a-z}={A-Z}"
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:*:*:descriptions' format "$completion_descriptions"
zstyle ':completion:*:*:*:*:corrections' format "$completion_error"
zstyle ':completion:*:*:*:*:warnings' format "$completion_warnings"
zstyle ':completion:*:*:*:*:messages' format "%d"

zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:approximate:*' max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )"
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns "*?.o" "*?.c~" "*?.old" "*?.pro"
zstyle ':completion:*:functions' ignored-patterns "_*"

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts \
  'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# FZF ==========================================================================

[[ -r ~/.config/themes/.current/fzf.zsh ]] && source ~/.config/themes/.current/fzf.zsh
