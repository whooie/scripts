#!/bin/bash

player_home="/media/music"
player_music="$player_home/Music"
player_playlists="$player_home/Playlists"

home_music="/home/whooie/Music"
home_playlists="/home/whooie/.config/mpd/playlists"

# blacklists:
artists=(
    # blacklisted artist directories
)
albums=(
    # blacklisted album directories
)
exclude_patterns=(
    # blacklisted patterns to catch the rest
)

declare -A blacklist
for i in "${!artists[@]}"; do
    blacklist["${artists[$i]}"]=$i
done
for i in "${!albums[@]}"; do
    blacklist["${albums[$i]}"]=$i
done

filetest(){ # 1:match 2:patterns
    local match=$1
    shift
    local -a patterns=("$@")
    for pattern in "${patterns[@]}"; do
        if [[ "$match" == $pattern ]]; then
            return 1
        fi
    done
    return 0
}

print-help() {
    echo -e "\e[1mUsage:\e[0m \e[1mmpsync\e[0m [ -p ] [ -m ] [ -R ]"
    echo -e "       \e[1mmpsync\e[0m [ -C ]"
    echo -e "       \e[1mmpsync\e[0m [ -P ]"
    echo -e "       \e[1mmpsync\e[0m [ -i ]"
    echo -e "       \e[1mmpsync\e[0m [ -b ]"
    echo -e "       \e[1mmpsync\e[0m [ -h|--help ]"
    echo -e ""
    echo -e "\e[1mOptions:\e[0m"
    echo -e "  -p           : Sync playlists"
    echo -e "  -m           : Sync music"
    echo -e "  -C           : Sync core items to the player's local storage"
    echo -e "  -c           : Get the total size of core items"
    echo -e "  -R           : Remove blacklisted items"
    echo -e "  -i           : Print last sync date"
    echo -e "  -b           : Print blacklist"
    echo -e "  -h,--help    : Print this info"
}

# recursive dfs through subdirectories and copy
dfscp(){ # 1:sourcedir 2:targetdir 3:offset
    if [[ -e "$2" ]]; then
        echo -e "\e[90m$3${2##*/}/\e[0m"
    elif [[ ${blacklist["${2##*/}"]} ]]; then
        return 0
    else
        echo -e "$3${2##*/}/"
        mkdir "$2"
    fi
    for item in "$1"/*; do
        if [[ -d "$item" ]] && [[ ! -z "$(ls "$item")" ]]; then
            dfscp "$item" "$2/${item##*/}" "$3  "
        else
            if ([[ ! -e "$2/${item##*/}" ]] || ([[ -e "$2/${item##*/}" ]] && [[ "$item" -nt "$2/${item##*/}" ]])) && [[ ! ${blacklist["${item##*/}"]} ]]; then
                if filetest "${item##*/}" "${exclude_patterns[@]}"; then
                    echo -e "$3  ${item##*/}"
                    cp "$item" "$2"
                else
                    echo -n ""
                fi
            else
                echo -e "\e[90m$3  ${item##*/}\e[0m"
            fi
        fi
    done
}

case $1 in
    -h|--help)
        print-help
        exit 0
        ;;
    "")
        print-help
        exit 1
        ;;
    *)
        while getopts "pmCcRib" opt; do
            case $opt in
                p)
                    echo "Looking for *.m3u in $home_playlists..."
                    for playlist in $home_playlists/*.m3u
                    do
                        filename=$(echo $playlist | awk 'BEGIN {FS="/"}{print $7}')
                        echo "  $filename"
                        sudo cat "$playlist" | awk '{print "/<microSD1>/Music/"$0}' > "$player_playlists/$filename"
                    done
                    sudo echo "Playlists last synced: $(date)" > "$player_playlists/last_sync"
                    ;;
                m)
                    echo "Copying from $home_music to $player_music..."
                    dfscp "$home_music" "$player_music" ""
                    sudo echo "Music last synced: $(date)" > "$player_music/last_sync"
                    ;;
                c)
                    size=$(cat "$home_playlists/Core.m3u" | while read file; do
                        du "$home_music/$file"
                    done | awk 'BEGIN{sum=0}{sum+=$1}END{print (sum/1000) "M"}')
                    echo "$size"
                    ;;
                R)
                    if [[ ! -e "$player_home/.PLAYER" ]]; then
                        for artist in "${artists[@]}"; do
                            if [[ -e "$player_music/$artist" ]]; then
                                echo "Remove $player_music/$artist"
                                sudo rm -rf "$player_music/$artist"
                            fi
                        done
                        for artist in $player_music/*; do
                            for album in "${albums[@]}"; do
                                if [[ -e "$artist/$album" ]]; then
                                    echo "Remove $artist/$album"
                                    sudo rm -rf "$artist/$album"
                                fi
                            done
                        done
                    else
                        for file in $player_music/*; do
                            sudo rm -rf $file
                        done
                    fi
                    ;;
                i)
                    cat "$player_playlists/last_sync"
                    cat "$player_music/last_sync"
                    exit 0
                    ;;
                b)
                    echo -e "\e[1mThe following have been blacklisted.\e[0m"
                    echo -e "\e[1mArtists:\e[0m"
                    for artist in "${artists[@]}"; do
                        echo "  $artist"
                    done | sort
                    echo -e "\e[1mAlbums:\e[0m"
                    for album in "${albums[@]}"; do
                        echo "  $album"
                    done | sort
                    echo -e "\e[1mOther Patterns:\e[0m"
                    for pattern in "${exclude_patterns[@]}"; do
                        echo "  $pattern"
                    done | sort
                    exit 0
                    ;;
                *)
                    echo "Invalid option -$opt"
                    print-help
                    exit 1
                    ;;
            esac
        done
        ;;
esac


