autoload -Uz compinit; compinit

# LOCAL/VARIABLES/ANSI =========================================================

local ANSI_reset="%f"
local ANSI_dim_black="%F{$THEME_DIM_BLACK_COLOR}"

# COLOR CUSTOMIZATION VARIABLES ===============================================
# Change these to customize theme colors
local THEME_BRANCH_COLOR="green"
local THEME_DIR_COLOR="green"
local THEME_ARROW_COLOR="yellow"
local THEME_GIT_STAGED_COLOR="green"
local THEME_GIT_UNSTAGED_COLOR="magenta"
local THEME_GIT_UNTRACKED_COLOR="blue"
local THEME_GIT_HASH_COLOR="magenta"
local THEME_SSH_COLOR="green"

# Additional theme variables for previously hardcoded colors
local THEME_ANSI_RESET_COLOR="default"
local THEME_DIM_BLACK_COLOR="black"
local THEME_VCS_ACTION_COLOR="black"
local THEME_ARROW_SEPARATOR_COLOR="black"
local THEME_COMPLETION_DESC_COLOR="green"
local THEME_COMPLETION_WARNING_COLOR="orange"
local THEME_COMPLETION_ERROR_COLOR="red"
local THEME_COMPLETION_MATCH_COLOR="green"

# Completion highlighting colors
local THEME_COMPLETION_HIGHLIGHT_COLOR="white"

# LOCAL/VARIABLES/GRAPHIC ======================================================

local char_arrow="›"                                            #Unicode: \u203a
local char_up_and_right_divider="└"                             #Unicode: \u2514
local char_down_and_right_divider="┌"                           #Unicode: \u250c
local char_vertical_divider="─"                                 #Unicode: \u2500

# SEGMENT/VCS_STATUS_LINE ======================================================

export VCS="git"

local current_vcs="\":vcs_info:*\" enable $VCS"
local char_badge=""
local vc_branch_name="%F{$THEME_BRANCH_COLOR}%b%f"

local vc_action="%F{$THEME_VCS_ACTION_COLOR}%a %f%F{$THEME_ARROW_SEPARATOR_COLOR}${char_arrow}%f"
local vc_unstaged_status="%F{$THEME_GIT_UNSTAGED_COLOR} M ${char_arrow}%f"

local vc_git_staged_status="%F{$THEME_GIT_STAGED_COLOR} A ${char_arrow}%f"
local vc_git_hash="%F{$THEME_GIT_HASH_COLOR}%6.6i%f %F{$THEME_ARROW_SEPARATOR_COLOR}${char_arrow}%f"
local vc_git_untracked_status="%F{$THEME_GIT_UNTRACKED_COLOR} U ${char_arrow}%f"

if [[ $VCS != "" ]]; then
  autoload -Uz vcs_info
  eval zstyle $current_vcs
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
fi

case "$VCS" in 
   "git")
    # git sepecific 
    zstyle ':vcs_info:git*+set-message:*' hooks use_git_untracked
    zstyle ':vcs_info:git:*' stagedstr $vc_git_staged_status
    zstyle ':vcs_info:git:*' unstagedstr $vc_unstaged_status
    zstyle ':vcs_info:git:*' actionformats "  ${vc_action} ${vc_git_hash}%m%u%c${char_badge} ${vc_branch_name}"
    zstyle ':vcs_info:git:*' formats " %c%u%m${char_badge} ${vc_branch_name}"
  ;;

  # svn sepecific 
  "svn")
    zstyle ':vcs_info:svn:*' branchformat "%b"
    zstyle ':vcs_info:svn:*' formats " ${char_badge} ${vc_branch_name}"
  ;;

  # hg sepecific 
  "hg")
    zstyle ':vcs_info:hg:*' branchformat "%b"
    zstyle ':vcs_info:hg:*' formats " ${char_badge} ${vc_branch_name}"
  ;;
esac

# Show untracked file status char on git status line
+vi-use_git_untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == "true" ]] &&
    git status --porcelain | grep -m 1 "^??" &>/dev/null; then
    hook_com[misc]=$vc_git_untracked_status
  else
    hook_com[misc]=""
  fi
}

# SEGMENT/SSH_STATUS ===========================================================

local ssh_marker=""

if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
 ssh_marker="%F{$THEME_SSH_COLOR}SSH%f%F{$THEME_ARROW_SEPARATOR_COLOR}:%f"
fi

# UTILS ========================================================================

setopt PROMPT_SUBST

# Prepare git status line
prepareGitStatusLine() {
  echo '${vcs_info_msg_0_}'
} 

# Prepare prompt line limiter
printPsOneLimiter() {
  local termwidth
  local spacing=""
  
  ((termwidth = ${COLUMNS} - 1))
  
  for i in {1..$termwidth}; do
    spacing="${spacing}${char_vertical_divider}"
  done
 
  # echo $ANSI_dim_black$char_down_and_right_divider$spacing$ANSI_reset
}

# ENV/VARIABLES/PROMPT_LINES ===================================================

PROMPT="${ssh_marker} %f%F{$THEME_DIR_COLOR}%1d%f$(prepareGitStatusLine)
%F{$THEME_ARROW_COLOR} ${char_arrow}%f "

RPROMPT=""

# ENV/HOOKS ==================================================================== 

precmd() {
  if [[ $VCS != "" ]]; then
    vcs_info
  fi
  printPsOneLimiter
  
  # Fix directory colors every time
  LS_COLORS=$(echo "$LS_COLORS" | sed 's/di=[^:]*://g' | sed 's/:di=[^:]*//g')
  LS_COLORS="di=31:$LS_COLORS"
  export LS_COLORS
}

# ENV/VARIABLES/LS_COLORS ======================================================

LSCOLORS=gxafexDxfxegedabagacad
export LSCOLORS

# Convert basic colors to ANSI codes for LS_COLORS
local ls_black="30"
local ls_blue="34"
local ls_yellow="33"
local ls_magenta="35"
local ls_red="31"
local ls_green="32"
local ls_white="37"

LS_COLORS="di=$ls_red:ln=$ls_black:so=$ls_blue:pi=$ls_yellow:ex=$ls_magenta:bd=$ls_blue:cd=$ls_blue:su=$ls_red:sg=$ls_red:ow=$ls_yellow:tw=$ls_green:*.js=$ls_yellow:*.json=$ls_yellow:*.jsx=$ls_red:*.ts=$ls_blue:*.css=$ls_blue:*.scss=$ls_magenta"
export LS_COLORS

# SEGMENT/COMPLETION ===========================================================

setopt MENU_COMPLETE

local completion_descriptions="%B%F{$THEME_COMPLETION_DESC_COLOR} ${char_arrow} %f%%F{$THEME_COMPLETION_MATCH_COLOR}%d%b%f"
local completion_warnings="%F{$THEME_COMPLETION_WARNING_COLOR} ${char_arrow} %fno matches for %F{$THEME_COMPLETION_MATCH_COLOR}%d%f"
local completion_error="%B%F{$THEME_COMPLETION_ERROR_COLOR} ${char_arrow} %f%e %d error"

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list "m:{a-z}={A-Z}"
zstyle ':completion:*' group-name ''

zstyle ':completion:*:*:*:*:descriptions' format $completion_descriptions
zstyle ':completion:*:*:*:*:corrections' format $completion_error
zstyle ':completion:*:*:*:*:default' list-colors "di=31:ln=30:so=34:pi=33:ex=35:bd=34:cd=34:su=31:sg=31:ow=33:tw=32:*.js=33:*.json=33:*.jsx=31:*.ts=34:*.css=34:*.scss=35" "ma=$ls_white"
zstyle ':completion:*:*:*:*:warnings' format $completion_warnings
zstyle ':completion:*:*:*:*:messages' format "%d"

zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:approximate:*' max-errors "reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )"
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns "*?.o" "*?.c~" "*?.old" "*?.pro"
zstyle ':completion:*:functions' ignored-patterns "_*"

zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# DIRECTORY COLOR OVERRIDE ====================================================
# Force directory color to red in completion by removing all di= entries and adding our own
LS_COLORS=$(echo "$LS_COLORS" | sed 's/di=[^:]*://g' | sed 's/:di=[^:]*//g')
LS_COLORS="di=$ls_red:$LS_COLORS"
export LS_COLORS

# SEGMENT/FZF ==================================================================

source ~/.config/themes/.current/fzf.zsh

