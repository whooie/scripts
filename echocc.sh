#!/bin/bash

term_width=$(tput cols)
term_height=$(tput lines)
text="$@"
clear
tput cup $(( $term_height/2 )) 0
printf "%*s\n" $(( (${#text}+$term_width)/2 )) "$text"
tput cup $term_height 0
