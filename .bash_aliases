
alias ls="exa --icons --color=auto"
alias l="ls -al --no-user"
alias tree="ls --tree"
alias c=clear
alias v=nvim
alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias def="xdg-open"
alias untar="tar -xvzf"
alias glone="git clone"
alias up='sudo systemctl start reflector.service; rustup update; yay --answerclean None --answerdiff None --noconfirm -Syyu; flatpak update --noninteractive'
alias updown='up;sleep 2; shutdown now'
alias pacdiff=eos-pacdiff
alias tt="tt -t 30 -theme one-dark"
alias hackerman="docker run -it --rm svenstaro/genact -m botnet"
alias todo="nvim ~/Documents/todo.txt"
alias init='flatpak run com.github.IsmaelMartinez.teams_for_linux >/dev/null 2>&1 & disown; flatpak run dev.vencord.Vesktop >/dev/null 2>&1 & disown; tutanota-desktop >/dev/null 2>&1 & disown;'


