set -o vi
bind 'set completion-ignore-case on'
shopt -s cdspell
complete -d cd
bind '"jk":vi-movement-mode'
export MANPAGER='nvim +Man!'

export EDITOR=nvim
export TERMINAL=kitty
export BROWSER=firefox

eval "$(starship init bash)"
source ~/.bash_aliases
