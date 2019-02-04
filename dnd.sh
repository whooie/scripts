#!/bin/bash

print-help(){
    n="\e[0m"
    b="\e[1m"
    u="\e[4m"

    echo -e "Simple command-line utility for DnD-related things."
    echo -e "Currently, only rolling has been implemented."
    echo -e "${b}Usage:${n} ${b}dnd${n} [ ${u}r${n}|${u}roll${n} ]"
    echo -e "       ${b}dnd${n} [ ${u}h${n}|${u}help${n} ]"
    echo -e "Commands:"
    echo -e "  r|roll ndk[ +|-m ]    Rolls n k-sided dice with optional modifier m."
    echo -e "                        Example: dnd r 2d20-5 rolls 2d20 and applies a"
    echo -e "                        minus five modifier to the sum."
}

roll(){
    if [[ $1 == "perc" ]] || [[ $1 == "p" ]]; then
        die=$(( $RANDOM % 100 + 1 ))
        echo "rollp:  $die"
        return
    fi
    
    IFS="d" read -a nd <<< "$1"
    if [[ ${nd[1]} == *"-"* ]]; then
        IFS="-" read -a dn <<< "${nd[1]}"
        dn[1]="-${dn[1]}"
    else
        IFS="+" read -a dn <<< "${nd[1]}"
    fi
    
    sum=0
    echo -n "rolls:"
    for (( i = 1; i <= ${nd[0]}; i++ )); do
        die=$(( $RANDOM % ${dn[0]} + 1 ))
        sum=$(( $sum + $die ))
        echo -n "  $die"
    done
    
    echo -en "\n"
    if [[ ${nd[0]} -gt 1 ]]; then
        echo -e "total:  $sum"
    fi
    
    if [[ ${dn[1]} != "" ]]; then
        mod=$(( $sum + ${dn[1]} ))
        echo "w/mod:  $mod"
    fi
}

case $1 in
    h|help)
        print-help
        exit 0
        ;;
    r|roll)
        shift
        roll "$@"
        ;;
    *)
        echo "Invalid command."
        print-help
        exit 0
esac
