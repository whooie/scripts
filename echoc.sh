#!/bin/bash

term_width=$(tput cols)
text="$@"
printf "%*s\n" $(( (${#text}+$term_width)/2 )) "$text"
