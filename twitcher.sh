#!/bin/bash

print-help(){
    n="\e[0m"
    b="\e[1m"
    u="\e[4m"

    echo -e "Frontend for mpv, youtube-dl, and twitchChatCLI."
    echo -e "${b}Usage:${n} ${b}twitcher${n} [ options ] ${u}channel${n}"
    echo -e "       ${b}twitcher${n} -h"
    echo -e "${b}Options:${n}"
    echo -e "  -S           Stream only."
    echo -e "  -F ${u}channel${n}   Print list of available youtube-dl formats."
    echo -e "  -f ${u}format${n}    Specify youtube-dl format. Default is best."
    echo -e "  -b           Run mpv in the background."
    echo -e "  -C           Chat only."
    echo -e "  -h           Display this text."
}


while [[ ${#@} -gt 0 ]]; do
    if [[ "${1:0:1}" == "-" ]]; then
        opt="${1:1}"
        for ((i = 0; i < ${#opt}; i++)); do
            case ${opt:$i:1} in
                S)
                    chat=false
                    fork=false
                    ;;
                F)
                    shift 1
                    youtube-dl -F "http://twitch.tv/$1"
                    exit 0
                    ;;
                f)
                    shift 1
                    format="$1"
                    break
                    ;;
                b)
                    fork=true
                    ;;
                C)
                    stream=false
                    ;;
                h)
                    print-help
                    exit 0
                    ;;
                *)
                    echo "Invalid option."
                    print-help
                    exit 1
                    ;;
            esac
        done
        shift 1
    else
        channel="$@"
        break
    fi
done

#for i in ${!channels[*]}; do
#    channels[$i]="http://twitch.tv/${channels[$i]}"
#done

if [[ ${stream:-true} == true ]]; then
    if [[ ${fork:-true} == true ]]; then
        mpv --no-terminal --ytdl-format="${format:-best}" "http://twitch.tv/$channel" &
    else
        mpv --ytdl-format="${format:-best}" "http://twitch.tv/$channel"
    fi
fi
if [[ ${chat:-true} == true ]]; then
    #if [[ -d $HOME/.config/twitcher ]]; then
    #    cd $HOME/.config/twitcher
    #else
    #    echo "Creating directory $HOME/.config/twitcher"
    #    mkdir $HOME/.config/twitcher
    #    cd $HOME/.config/twitcher
    #fi
    #./twitchChatCLI-linux-amd64 "$channel"
    irssi --connect="irc.chat.twitch.tv"
fi
