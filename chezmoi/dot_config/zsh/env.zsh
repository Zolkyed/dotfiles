export EDITOR="nvim"
export VISUAL="$EDITOR"
export BROWSER="brave"
export PAGER="less"
export MANPAGER="less"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"

setopt autocd extendedglob nomatch menucomplete
setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks hist_verify

command -v atuin &>/dev/null && eval "$(atuin init zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
