ZSH_DISABLE_COMPFIX=true

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='bat'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BROWSER='brave'

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

setopt hist_verify auto_cd auto_pushd pushd_ignore_dups pushd_silent correct

# Vague-themed LS_COLORS for colored completions
[[ -f $HOME/.config/zsh/dircolors ]] && eval "$(dircolors $HOME/.config/zsh/dircolors)"

# Volta (Node version manager)
export VOLTA_HOME="$HOME/.volta"
path=("$VOLTA_HOME/bin" $path)
