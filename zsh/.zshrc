HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS

zstyle :compinstall filename '$HOME/.zshrc'

# Homebrew
export HOMEBREW_NO_ENV_HINTS=1

# Ollama
export OLLAMA_KEEP_ALIVE=60

# Prompt
autoload -U promptinit; promptinit
prompt typewritten
TYPEWRITTEN_CURSOR="block"
TYPEWRITTEN_RELATIVE_PATH="home"

# Enable Colors
autoload -U colors && colors

# Key bindings
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Path
export PATH="$HOME/Git/scripts:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.python/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$GOPATH/bin:$PATH"
# Homebrew adds pbcopy/pbpaste and other macOS CLI tools
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Remove ESC key binding
bindkey -r '\e'

# Environment variables
export EDITOR=nvim

# Basic auto/tab complete:
autoload -Uz compinit bashcompinit
compinit
bashcompinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)

# Auto cd
setopt autocd

alias la="ls -lhaG"
alias ls="ls -G"
alias ll="ls -lhG"
alias so='source $HOME/.zshrc'
alias untar='tar xvf'
alias rf='rm -rvf'
alias mv='mv -i'
alias suv='sudo nvim'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias cp='cp -r'
alias t='tmux'
alias top='btop'
orphs() {
  command -v brew >/dev/null 2>&1 || { echo "Homebrew not found."; return 1; }
  echo "Cleaning Homebrew leaves..."
  brew autoremove
  brew cleanup
}

unzipf() {
    if [ -z "$2" ]; then
        folder=$(echo "$1" | head -c -5)
    else
        folder=$(echo "$2")
    fi
    command unzip $1 -d $folder
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/rasul/.lmstudio/bin"
# End of LM Studio CLI section

