#!/bin/bash

#menu="dmenu -fn "Tamsyn" -nb "#1a1a1c" -nf "#a0a0a0" -sb "#284c8a" -sf "#ffffff" -x 8 -y 8 -w 1904 -h 24"
menu="dmenu -fn "Tamsyn" -nb "#1a1a1c" -nf "#a0a0a0" -sb "#32394e" -sf "#ffffff" -x 8 -y 8 -w 1904 -h 24"
#answer="$(echo "$@" | bc -l)"
input="$@"
answer="$(python -c "import math as m; import random as r; print(1.0*$input)")"
action=$(echo -e "Clear\nCopy\nClose" | $menu -p "= $answer")
case $action in
    "Clear")
        $0
        ;;
    "Copy")
        echo $answer | tr -d '\n' | xclip
        ;;
    "Close")
        ;;
    *)
        $0 "$answer $action"
        ;;
esac
