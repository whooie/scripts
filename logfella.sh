#!/bin/bash

time_format="+[%H:%M:%S]"
date_format="+%a %Y.%m.%d %H:%M:%S"

def_logfile="./logfile"

def_overwrite="no"
confirm_del="yes"

print-help(){
    b="\e[1m"
    u="\e[4m"
    n="\e[0m"

    echo -e "Records notes with time/date information to a file."
    echo -e "Type the note at the prompt, then press the 'return' key to enter it into the log."
    echo -e "Type '/quit' to stop recording."
    echo -e "${b}Usage:${n} ${b}logfella${n} [ -f ${u}file${n} ] [ -y|Y ]"
    echo -e "       ${b}logfella${n} [ -h ]"
    echo -e "Options:"
    echo -e "  -f ${u}file${n}       Specify the path (absolute or relative) to the desired log file."
    echo -e "                  If ${u}file${n} already exists, exit. See options -y and -Y to override"
    echo -e "                  this behavior. If -f is not specified, the default is ./logfile."
    echo -e "  -y            Add to a log file if it already exists."
    echo -e "  -Y            Delete the log file if it already exists before writing. You will"
    echo -e "                  be prompted to confirm before the pre-existing file is deleted."
    echo -e "  -m ${u}message${n}    Add a message to the first line of a log session."
    echo -e "  -h            Display this text and exit."
}


while [[ ${#@} -gt 0 ]]; do
    if [[ "${1:0:1}" == "-" ]]; then
        opt="${1:1}"
        for ((i = 0; i < ${#opt}; i++)); do
            case ${opt:$i:1} in
                f)
                    shift 1
                    logfile="$1"
                    ;;
                y)
                    overwrite="soft"
                    ;;
                Y)
                    overwrite="hard"
                    ;;
                m)
                    shift 1
                    message=" - $1"
                    ;;
                h)
                    print-help
                    exit 0
                    ;;
                *)
                    echo "Invalid option '-${opt:$i:1}'."
                    print-help
                    exit 1
                    ;;
            esac
        done
        shift 1
    else
        echo "Invalid operand '$1'."
        print-help
        exit 1
    fi
done
[[ ! -n "$logfile" ]] && logfile="$def_logfile"
[[ ! -n "$overwrite" ]] && overwrite="$def_overwrite"

if [[ -e "$logfile" ]]; then
    case $overwrite in
        no)
            echo "Log file '$logfile' already exists; exit with error code."
            echo "See 'logfella -h' if you wish to override this behavior."
            exit 1
            ;;
        soft)
            echo "Log file '$logfile' already exists; '-y' was specified."
            echo "" >> "$logfile"
            ;;
        hard)
            echo "Log file '$logfile' already exists; '-Y' was specified."
            while [[ $confirm_del == "yes" ]]; do
                read -p "Delete? [y|N] " choice </dev/tty
                case $choice in
                    y|Y)
                        rm "$logfile"
                        confirm_del="no"
                        ;;
                    n|N|"")
                        exit 1
                        ;;
                    *)
                        echo "Invalid choice."
                        ;;
                esac
                echo ""
            done
            ;;
    esac
fi

write="yes"
echo ":: SESSION START - $(date "$date_format")$message"
echo ":: SESSION START - $(date "$date_format")$message" >>"$logfile"
while [[ $write == "yes" ]]; do
    read -p ">> " input </dev/tty
    if [[ "$input" == "/"* ]]; then
        read -ra line <<<"$input"
        case ${line[0]:1} in
            quit)
                echo ":: SESSION END - $(date "$date_format")"
                echo ":: SESSION END - $(date "$date_format")" >>"$logfile"
                write="no"
                ;;
            *)
                echo "Invalid command."
                ;;
        esac
    else
        input="$(date "$time_format") $input"
        term_width=$(tput cols)
        tput cuu $[${#input}/$term_width + 1]
        echo "$input"
        echo "$input" >>"$logfile"
    fi
done
