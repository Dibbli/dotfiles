# Created by newuser for 5.9
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

# Enable vi mode
bindkey -v

# Ignore case in completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{A-Z}={a-z}'

# Fix minor typos in directory names
setopt correct

# Completion for `cd` to only list directories
zstyle ':completion:*:*:cd:*' tag-order local-directories

# Custom keybinding for Zsh's vi mode
bindkey 'jk' vi-cmd-mode

# Configure completion system
zstyle :compinstall filename '/home/dibbli/.zshrc'

autoload -Uz compinit
compinit

# Export variables
export LINGO_20_HOME="~/.cache/yay/lingo/src/usr/share/lingo"
export VOLTA_HOME="$HOME/.volta"
export EM_CACHE=~/.emscripten_cache
export ANDROID_HOME=$HOME/Android/Sdk
export LUA_PATH="/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;;"
export LUA_CPATH="/usr/lib/lua/5.1/?.so;;"
export MANPAGER='nvim +Man!'
export EDITOR=nvim
export TERMINAL=kitty
export BROWSER=librewolf

# Update PATH
export PATH=~/.cache/yay/lingo/src/usr/share/lingo:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=/usr/lib/emscripten:$PATH
export PATH=$HOME/.local/share/nvim/mason/bin:$PATH
export PATH=$VOLTA_HOME/bin:$PATH
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
export PATH=/home/dibbli/.volta/bin/npx:$PATH

# Load pywal colors
cat ~/.cache/wal/sequences
source ~/.cache/wal/colors-tty.sh

# Initialize Starship prompt
eval "$(starship init zsh)"

# Source aliases (if they exist)
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
