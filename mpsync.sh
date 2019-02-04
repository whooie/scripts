#!/bin/bash

player_home="/media/music"
player_music="$player_home/Music"
player_playlists="$player_home/Playlists"

home_music="/home/whooie/Music"
home_playlists="/home/whooie/.config/mpd/playlists"

core=("Core.m3u" "Shortlist.m3u" "Shortlist Part I.m3u" "Shortlist Part II.m3u" "Instrumentals.m3u")

# blacklists:
artists=(
    "38 Special"
    "Aaron Copland"
    "AC-DC"
    "Aerosmith"
    "Alex S"
    "Arai Akino"
    "Asami Imai"
    "Beatles, The"
    "BlackGryph0n"
    "Bob Seger"
    "Bryan Adams"
    "Curtis Schweitzer"
    "Daniel Ingram"
    "David Rolfe"
    "Eagles, The"
    "ENA"
    "Eric Johnson"
    "Foghat"
    "Fukuhara Miho"
    "Galileo Galilei"
    "Game Freak & Shota Kageyama"
    "Green Day"
    "Hayami Saori & Touyama Nao"
    "Huey Lewis & The News"
    "Iwasaki Taisei"
    "John Williams"
    "Kana-Boon"
    "Konomi Suzuki"
    "Nana Kitade"
    "Niel Zaza"
    "Nintendo"
    "Phil Collins"
    "PJ Lequerica"
    "Protomen, The"
    "Queen"
    "REO Speedwagon"
    "Rob Thomas"
    "Russell Velazquez"
    "Sangatsu no Phantasia"
    "Scenarioart"
    "Shigatsu wa Kimi no Uso"
    "Smashing Pumpkins"
    "Streetlight Manifesto"
    "Styx"
    "Survivor"
    "Tara Strong"
    "Tomatsu Haruka"
    "Zoe Keating"
    "ZZ Top"
)
albums=(
    "1984"
    "50 Most Essential Pieces of Classical Music, The"
    "Ame no Umi"
    "Aqua Terrarium"
    "Axis Bold As Love"
    "Big Dark Love"
    "Dear Answer"
    "FLCL Progressive-Alternative Complete Box Set - Disk 2"
    "FLCL Progressive-Alternative Complete Box Set - Disk 3"
    "Gamecube Controller Whitenoise"
    "Gekkan Shoujo Nozaki-kun Vol.3 Special CD Complete Soundtrack"
    "Its Easier To Be Somebody Else"
    "Poutine Split"
    "Sound Checks"
    "Trinity"
    "Ultimate Collection, The"
    "Walk On"
    "We Need Medicine"
)
exclude_patterns=(
    "*- Arienai*"
    "*.jpg"
    "*.png"
    "*.pdf"
    "*- Radio*"
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
                    #SAVEIFS=$IFS
                    #IFS=$(echo -en "\n\b")
                    #for artist in $home_music/*
                    #do
                    #    artist_name=$(echo $artist | awk 'BEGIN{FS="/"}{print $5}')
                    #    if [[ ! -e "$player_music/$artist_name" ]]
                    #    then
                    #        echo "$player_music/$artist_name"
                    #        sudo rsync -rP "${artists_exclude[@]}" "${albums_exclude[@]}" "${files_exclude[@]}" "$artist" "$player_music"
                    #    else
                    #        echo -e "\e[90m$player_music/$artist_name found\e[0m"
                    #        for album in $artist/*
                    #        do
                    #            album_name=$(echo $album | awk 'BEGIN{FS="/"}{print $6}')
                    #            if [[ ! -e "$player_music/$artist_name/$album_name" ]]
                    #            then
                    #                echo "$player_music/$artist_name/$album_name"
                    #                sudo rsync -rP "${albums_exclude[@]}" "${files_exclude[@]}" "$album" "$player_music/$artist_name"
                    #            else
                    #                echo -e "\e[90m$player_music/$artist_name/$album_name found\e[0m"
                    #                for file in $album/*
                    #                do
                    #                    file_name=$(echo $file | awk 'BEGIN{FS="/"}{print $7}')
                    #                    if [[ ! -e "$player_music/$artist_name/$album_name/$file_name" ]] || [[ "$file" -nt "$player_music/$artist_name/$album_name/$file_name" ]]
                    #                    then
                    #                        echo "$player_music/$artist_name/$album_name/$file_name"
                    #                        sudo rsync -rP "${files_exclude[@]}" "$file" "$player_music/$artist_name/$album_name"
                    #                    else
                    #                        echo -e "\e[90m$player_music/$artist_name/$album_name/$file_name omitted\e[0m"
                    #                    fi
                    #                done
                    #            fi
                    #        done
                    #    fi
                    #done
                    #IFS=$SAVEIFS
                    sudo echo "Music last synced: $(date)" > "$player_music/last_sync"
                    ;;
                C)
                    if [[ ! -e "$player_home/.PLAYER" ]]; then
                        echo "This option should only be used to copy music to the player's local memory."
                        exit 1
                    fi
                    for i in ${!core[@]}; do
                        echo "Copying playlist ${core[i]}..."
                        sudo cat "$home_playlists/${core[i]}" | awk 'BEGIN{FS="/"}{print "/Music/"$3}' > "$player_playlists/${core[i]}"
                        if [[ ${core[i]} == "Core.m3u" ]]; then
                            echo "Copying the Core..."
                            cat "$home_playlists/${core[i]}" | while read file; do
                                filename=$(echo $file | awk 'BEGIN{FS="/"}{print $3}')
                                if [[ ! -e "$player_music/$filename" ]] || [[ "$file" -nt "$player_music/$filename" ]]; then
                                    echo "$player_music/$filename"
                                    sudo rsync -rP "$home_music/$file" "$player_music"
                                else
                                    echo -e "\e[90m$player_music/$filename omitted\e[0m"
                                fi
                            done
                            sudo echo "Music last synced: $(date)" > "$player_music/last_sync"
                        fi
                    done
                    sudo echo "Playlists last synced: $(date)" > "$player_playlists/last_sync"
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


