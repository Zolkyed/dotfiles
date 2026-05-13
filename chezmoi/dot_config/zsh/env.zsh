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

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"

setopt hist_ignore_all_dups hist_ignore_space hist_reduce_blanks hist_verify
setopt share_history extended_history
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent correct

# NVM lazy load
export NVM_DIR="$HOME/.nvm"
_nvm_load() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}
nvm()  { _nvm_load; nvm  "$@"; }
node() { _nvm_load; node "$@"; }
npm()  { _nvm_load; npm  "$@"; }
npx()  { _nvm_load; npx  "$@"; }
