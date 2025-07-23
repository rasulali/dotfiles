HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS

zstyle :compinstall filename '$HOME/.zshrc'

# Prompt
fpath+=$HOME/Git/typewritten
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
export PATH="$HOME/Git/scripts/:$PATH"
export PATH="$HOME/.cargo/bin/:$PATH"
export PATH="/home/rasul/.python/bin:$PATH"
export PATH="/home/rasul/.local/bin:$PATH"

# Remove ESC key binding
bindkey -r '\e'

# Environment variables
export EDITOR=nvim

# Basic auto/tab complete:
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)

# Auto cd
setopt autocd

# custom aliases
alias so='source $HOME/.zshrc'
alias la="ls -lhAtU --color=auto"
alias ls="ls -t --group-directories-first  --color=auto"
alias ll="ls -lhtU --color=auto"
alias untar='tar xvf'
alias rf='rm -rvf'
alias mv='mv -i'
alias suv='sudo nvim'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias cp='cp -r'
alias t='tmux'
alias top='glances'
orphs() {
  local pkgs=$(yay -Qdtq)
    if [ -z "$(echo $pkgs)" ]; then
      echo -e "\e[1;32mThere are no orphan packages on system\e[0m"
    else
        sudo yay -Rns $(echo $pkgs)
    fi
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
[ -s "/home/rasul/.bun/_bun" ] && source "/home/rasul/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
