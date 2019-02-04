#!/bin/bash

print-help(){
    n="\e[0m"
    b="\e[1m"
    u="\e[4m"

    echo -e "Frontend for mpv streaming and youtube-dl."
    echo -e "${b}Usage:${n} ${b}mpv-s${n} [ -f ${u}format${n} ] { ${u}URL${n}... } [[ -f ${u}format${n} ] { ${u}URL${n}... } ...]"
    echo -e "       ${b}mpv-s${n} -F { ${u}URL${n}... }"
    echo -e "       ${b}mpv-s${n} -h"
    echo -e ""
    echo -e "${b}Options:${n}"
    echo -e "  -f           Specify a stream format (see -F)"
    echo -e "  -F           Get a list of youtube-dl formats for the URL"
    echo -e "  -h,--help    Print this info"
}

case $1 in
    "")
        print-help
        exit 1
        ;;
    -h|--help)
        print-help
        exit 0
        ;;
esac

while [[ ${#@} -gt 0 ]]; do
    if [[ "${1:0:1}" == "-" ]]; then
        opt="${1:1}"
        for ((i = 0; i < ${#opt}; i++)); do
            case ${opt:$i:1} in
                f)
                    format="$2"
                    shift 1
                    ;;
                F)
                    shift 1
                    youtube-dl -F $@
                    exit 0
                    ;;
                *)
                    echo "Invalid option ${opt:$i:1}"
                    print-help
                    exit 1
                    ;;
            esac
        done
        shift 1
    else
        read -ra files <<< "$(echo "$@" | awk 'BEGIN{FS=" -"}{print $1}')"
        mpv --ytdl-format ${format:-bestvideo+bestaudio} ${files[*]} || mpv --ytdl-format ${format:-best} ${files[*]}
        shift ${#files[@]}
    fi
done
