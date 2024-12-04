set -o vi
bind 'set completion-ignore-case on'
shopt -s cdspell
complete -d cd
bind '"jk":vi-movement-mode'
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
export PATH=~/.cache/yay/lingo/src/usr/share/lingo:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=/usr/lib/emscripten:$PATH
export PATH=$HOME/.local/share/nvim/mason/bin:$PATH
export PATH=$VOLTA_HOME/bin:$PATH
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
export PATH=/home/dibbli/.volta/bin/npx:$PATH
export MANPAGER='nvim +Man!'
cat ~/.cache/wal/sequences
source ~/.cache/wal/colors-tty.sh
eval "$(starship init bash)"
source ~/.bash_aliases
