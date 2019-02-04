#!/bin/bash

name="Circinus"
address="00:1A:7D:DA:71:11"

print-help(){
    n="\e[0m"
    b="\e[1m"
    u="\e[4m"

    echo -e "Frontend for tools provided by bluez-tools."
    echo -e "Specifically controls the adapter aliased $name ($address)."
    echo -e "${b}Usage:${n} ${b}circinus${n} [ options ]"
    echo -e "       ${b}circinus${n} -h"
    echo -e "${b}Options:${n}"
    echo -e "  -i                            Get info about $name"
    echo -e "  -d                            Discover devices"
    echo -e "  -s ${u}property${n} ${u}value${n}             Set property for $name"
    echo -e "                                Valid properties and values are:"
    echo -e "                                  Alias ${u}str${n}"
    echo -e "                                  Discoverable ${u}1${n}|${u}0${n}"
    echo -e "                                  DiscoverableTimout ${u}int${n}"
    echo -e "                                  Pairable ${u}1${n}|${u}0${n}"
    echo -e "                                  PairableTimeout ${u}int${n}"
    echo -e "                                  Powered ${u}1${n}|${u}0${n}"
    echo -e "  -p ${u}1${n}|${u}0${n}                        Shortcut to ${b}circinus${n} -s Powered ${u}1${n}|${u}0${n}"
    echo -e "  -L                            List added devices"
    echo -e "  -C ${u}mac${n}                        Connect to a device"
    echo -e "  -D ${u}name${n}|${u}mac${n}                   Disconnect from a device"
    echo -e "  -R ${u}name${n}|${u}mac${n}                   Remove device"
    echo -e "  -I ${u}name${n}|${u}mac${n}                   Get info about a device"
    echo -e "  -S ${u}name${n}|${u}mac${n} ${u}property${n} ${u}value${n}    Set device property"
    echo -e "                                Valid properties and values are:"
    echo -e "                                  Alias ${u}str${n}"
    echo -e "                                  Trusted ${u}1${n}|${u}0${n}"
    echo -e "                                  Blocked ${u}1${n}|${u}0${n}"
    echo -e "  -h                            Display this text"
}

if ! (bt-adapter -l | grep "$address" >/dev/null); then
    echo "$name is not connected."
    if [[ "$1" != "-h" ]]; then
        exit 1
    fi
fi

while [[ ${#@} -gt 0 ]]; do
    if [[ "${1:0:1}" == "-" ]]; then
        opt="${1:1}"
        for ((i = 0; i < ${#opt}; i++)); do
            case ${opt:$i:1} in
                i)
                    bt-adapter --adapter="$address" -i
                    ;;
                d)
                    bt-adapter --adapter="$address" -d
                    ;;
                s)
                    bt-adapter --adapter="$address" --set "$2" "$3"
                    shift 2
                    ;;
                p)
                    bt-adapter --adapter="$address" --set Powered "$2"
                    shift 1
                    ;;
                L)
                    bt-device --adapter="$address" --list
                    ;;
                C)
                    bt-device --adapter="$address" --connect="$2"
                    shift 1
                    ;;
                D)
                    bt-device --adapter="$address" --disconnect="$2"
                    shift 1
                    ;;
                R)
                    bt-device --adapter="$address" --remove="$2"
                    shift 1
                    ;;
                I)
                    bt-device --adapter="$address" --info="$2"
                    shift 1
                    ;;
                S)
                    bt-device --adapter="$address" --set "$2" "$3" "$4"
                    shift 3
                    ;;
                h)
                    print-help
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
    fi
done
