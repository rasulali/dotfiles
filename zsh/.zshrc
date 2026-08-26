HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS

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

# Homebrew adds pbcopy/pbpaste and other macOS CLI tools
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Environment variables
export EDITOR=nvim
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH="$HOME/.local/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# Basic auto/tab complete:
autoload -Uz compinit bashcompinit
compinit
bashcompinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)

# Auto cd
setopt autocd

# yt-dlp
alias yta='yt-dlp -f bestaudio[ext=m4a] -o "~/Music/Local/%(title)s.%(ext)s"'
alias ytal='yt-dlp -f bestaudio[ext=m4a] --yes-playlist -o "~/Music/Local/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'

# eza / ls
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first --color=auto'
  alias ll='eza -lh --icons --group-directories-first --color=auto'
  alias la='eza -lha --icons --group-directories-first --color=auto'
else
  alias ls='ls -G'
  alias ll='ls -lhG'
  alias la='ls -lhaG'
fi

alias so='source $HOME/.zshrc'
alias untar='tar xvf'
alias rf='rm -rf'
alias mv='mv -i'
alias suv='sudo nvim'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'
alias cp='cp -r'
alias t='tmux'
alias top='sudo asitop'
alias cc='claude --dangerously-skip-permissions'

orphs() {
  command -v brew >/dev/null 2>&1 || { echo "Homebrew not found."; return 1; }
  echo "Cleaning Homebrew leaves..."
  brew autoremove
  brew cleanup
}

unzipf() {
  if [ -z "$1" ]; then
    echo "Usage: unzipf <file.zip> [target_dir]" >&2
    return 1
  fi

  local zipfile="$1"
  local folder

  if [ -z "$2" ]; then
    folder="${zipfile%.zip}"
  else
    folder="$2"
  fi

  mkdir -p -- "$folder" || return 1
  command unzip "$zipfile" -d "$folder"
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/rasul/.lmstudio/bin"
# End of LM Studio CLI section

# Docker CLI
fpath=(/Users/rasul/.docker/completions $fpath)

# Conda
source /opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh
export PATH="$HOME/.grok/bin:$PATH"
