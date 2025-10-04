unbind C-b
set-option -g prefix Home 
bind-key Home send-prefix

set -g base-index 1
setw -g pane-base-index 1
set -g mouse on

set-window-option -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'

bind -n C-k clear-history

# Create right pane with 30% width and run claude, or focus if exists
bind-key a run-shell "~/.config/tmux/claude-toggle.sh"

source-file ~/.config/tmux/current-theme.tmuxtheme

set -as terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'jimeh/tmuxifier'

run '~/.config/tmux/plugins/tpm/tpm'
