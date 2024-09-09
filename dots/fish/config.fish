# kaawai fetch

pfetch

# remove welcome 
set -g fish_greeting


#allias 


function ls
    lsd 
end


function dclean
    rm drw.o dwm.o dwm-msg.o util.o config.h
end

function dmake
    sudo make clean install
end

function ff
    fastfetch $argv
end

function cat
    bat
end

function updt
    sudo pacman -Syu && paru
end

function in
    sudo pacman -S $argv
end


function out
    sudo pacman -R $argv
end

function exile
    sudo pacman -Rs $argv
end

function pin
    paru $argv
end


function vim 
   nvim $argv
end


# If commands runs >= 10 seconds, notify user on completion
if test $CMD_DURATION
    if test $CMD_DURATION -gt (math "1000 * 10")
        set secs (math "$CMD_DURATION / 1000")
        notify-send "$history[1]" "Returned $status, took $secs seconds"
    end
end

# set PATH
set -gx PATH ~/.local/bin $PATH

# init
oh-my-posh init fish --config ~/.config/omp/promt.toml | source
zoxide init fish | source
fzf --fish | source

fish_add_path /home/kolpona/.spicetify
