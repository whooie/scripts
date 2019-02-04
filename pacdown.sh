#!/bin/bash

print-help(){
    n="\e[0m"
    b="\e[1m"
    u="\e[4m"

    echo -e "Generate a list of package files for a system downgrade."
    echo -e "Assumes a default pacman cache configuration."
    echo -e "${b}Usage:${n} ${b}pacdown${n} [ -d ${u}YYYY-MM-DD${n} ] [ -f ${u}file${n} ]"
    echo -e "       ${b}pacdown${n} -h"
    echo -e "${b}Options:${n}"
    echo -e "  -d ${u}YYYY-MM-DD${n}     Specify the date of the upgrade you wish to reverse."
    echo -e "                    Default is the current date."
    echo -e "  -f ${u}file${n}           Specify the location of the file containing the list of packages."
    echo -e "                    Default is './downgrade'."
    echo -e "  -y <${u}hard${n}|${u}soft${n}|${u}no${n}> Controls list-overwriting behavior. ${u}hard${n} deletes the list,"
    echo -e "                    ${u}soft${n} adds to the list, and ${u}no${n} exits if a pre-existing list is found."
    echo -e "                    Default is ${u}no${n}."
    echo -e "  -h                Print this text."
}

while [[ ${#@} -gt 0 ]]; do
    if [[ "${1:0:1}" == "-" ]]; then
        opt="${1:1}"
        for ((i = 0; i < ${#opt}; i++)); do
            case ${opt:$i:1} in
                d)
                    shift 1
                    date=$1
                    ;;
                f)
                    shift 1
                    file=$1
                    ;;
                y)
                    shift 1
                    over=$1
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
[[ -n "$date" ]] || date=$(date "+%Y-%m-%d")
[[ -n "$file" ]] || file="downgrade"
[[ -n "$over" ]] || over="no"

if [[ "$over" == "no" ]] && [[ -e "$file" ]]; then
    echo "List file already exists."
    exit 1
fi
if [[ "$over" == "hard" ]] && [[ -e "$file" ]]; then
    rm "$file"
fi

grep -e "$date.*ALPM.*upgrade" "/var/log/pacman.log" | awk '{print $5 $6}' | tr "(" "-" | while read pkg; do
    if [[ -e "/var/cache/pacman/pkg/$pkg-x86_64.pkg.tar.xz" ]]; then
        echo "/var/cache/pacman/pkg/$pkg-x86_64.pkg.tar.xz" >> "$file"
    else
        echo "/var/cache/pacman/pkg/$pkg-any.pkg.tar.xz" >> "$file"
    fi
done

declare -a errs
i=0
while read pkg; do
    if [[ ! -e "$pkg" ]]; then
        errs[$i]="$pkg"
        i=$[i+1]
    fi
done < "$file"
if [[ ${#errs[@]} -gt 0 ]]; then
    echo "$i possible filename error(s):"
    for pkg in "${errs[@]}"; do
        echo "  $pkg"
    done
fi
