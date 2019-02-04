#!/bin/bash

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
