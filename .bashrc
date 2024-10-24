set -o vi
bind 'set completion-ignore-case on'
shopt -s cdspell
complete -d cd
bind '"jk":vi-movement-mode'

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export LINGO_20_HOME="~/.cache/yay/lingo/src/usr/share/lingo"
export PATH="~/.cache/yay/lingo/src/usr/share/lingo:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
export LUA_PATH="/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;;"
export LUA_CPATH="/usr/lib/lua/5.1/?.so;;"
export MANPAGER='nvim +Man!'
export EDITOR=nvim
export TERMINAL=kitty
export BROWSER=librewolf

cat ~/.cache/wal/sequences
source ~/.cache/wal/colors-tty.sh
eval "$(starship init bash)"
source ~/.bash_aliases
