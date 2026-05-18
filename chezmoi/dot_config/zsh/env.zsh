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

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify auto_cd auto_pushd pushd_ignore_dups pushd_silent no_beep

export BAT_THEME="base16"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="
  --layout=reverse --border=none --height=40%
  --color=fg:#c5c8c6,bg:#1d1f21,hl:#7fa563
  --color=fg+:#ffffff,bg+:#2a2d2e,hl+:#7fa563
  --color=info:#606079,prompt:#d8647e,pointer:#d8647e
  --color=marker:#7fa563,spinner:#606079,header:#606079
"

_fzf_file_preview="if [ -d {} ]; then eza --tree --color=always --icons {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$_fzf_file_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"

# Volta (Node version manager)
export VOLTA_HOME="$HOME/.volta"
path=("$VOLTA_HOME/bin" $path)
