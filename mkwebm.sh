#!/bin/bash

print-help() {
    echo -e "Frontend for ffmpeg to create webms."
    echo -e "\e[1mUsage:\e[0m \e[1mmkwebm\e[0m [ \e[4mopts\e[0m ] \e[1m-i\e[0m \e[4minput video\e[0m \e[1m-o\e[0m \e[4moutput gif\e[0m"
    echo -e "       \e[1mmkwebm\e[0m [ -h ]"
    echo -e "\e[1mOptions:\e[0m"
    echo -e "  \e[1m-i\e[0m <\e[4mfile\e[0m>            Input video file."
    echo -e "  \e[1m-o\e[0m <\e[4mfile\e[0m>            Output gif file."
    echo -e "  \e[1m-a\e[0m <\e[4mhh\e[0m:\e[4mmm\e[0m:\e[4mss\e[0m.\e[4ms\e[0m>      Starting position. Defaults to \e[1m00:00:00.0\e[0m."
    echo -e "  \e[1m-t\e[0m <\e[4mhh\e[0m:\e[4mmm\e[0m:\e[4mss\e[0m:\e[4ms\e[0m>      Duration. Defaults to \e[1m10:00:00.0\e[0m."
    echo -e "  \e[1m-f\e[0m <\e[4mint\e[0m>             Framerate of the output. Use \e[1m-1\e[0m to use the same framerate as the input."
    echo -e "                         Defaults to the input's framerate."
    echo -e "  \e[1m-d\e[0m <\e[4mwidth\e[0m:\e[4mheight\e[0m>    Dimensions of the output. Use \e[1m-1\e[0m to use the same width or height as the"
    echo -e "                         input or a length which would preserve the input's aspect ratio. Defaults"
    echo -e "                         to the dimensions of the input. There is no syntax check here, so expect"
    echo -e "                         ffmpeg errors if something is wrong with this option."
    echo -e "  \e[1m-s\e[0m <\e[4mmode\e[0m>            Scaling mode. Can be \e[1mbilinear\e[0m, \e[1mlanczos\e[0m, or \e[1mbicubic\e[0m. Defaults to \e[1mlanczos\e[0m."
    echo -e "  \e[1m-q\e[0m <\e[4mint\e[0m>             Quality level (\e[1m0\e[0m-\e[1m63\e[0m). \e[1m31\e[0m is recommended for 1080p"
    echo -e "                         video. Defaults to \e[1m25\e[0m."
    echo -e "  \e[1m-S\e[0m <\e[4mmode\e[0m>            Subtitle mode. Can be \e[1mhard\e[0m, \e[1msoft\e[0m, or \e[1mno\e[0m. Defaults to \e[1mno\e[0m."
    #echo -e "  \e[1m-x\e[0m <\e[4mopts\e[0m>            Specify any extra ffmpeg input arguments. Syntax is not checked."
    #echo -e "  \e[1m-y\e[0m <\e[4mopts\e[0m>            Specift any extra ffmpeg output arguments. Syntax is not checked."
}

calculate_end_time() {
    shh=$(echo $1 | awk 'BEGIN{FS=":"}{print $1}')
    smm=$(echo $1 | awk 'BEGIN{FS=":"}{print $2}')
    sss=$(echo $1 | awk 'BEGIN{FS=":"}{print $3}')

    thh=$(echo $2 | awk 'BEGIN{FS=":"}{print $1}')
    tmm=$(echo $2 | awk 'BEGIN{FS=":"}{print $2}')
    tss=$(echo $2 | awk 'BEGIN{FS=":"}{print $3}')

    ehh=$(bc <<< "$shh+$thh")
    emm=$(bc <<< "$smm+$tmm")
    ess=$(bc <<< "$sss+$tss")

    if (( $(bc <<< "$ess >= 60") )); then
        emm=$(bc <<< "$emm + 1")
        ess=$(bc <<< "$ess - 60")
    fi
    if (( $(bc <<< "$emm >= 60") )); then
        ehh=$(bc <<< "$ehh + 1")
        emm=$(bc <<< "$emm - 60")
    fi

    if (( $(bc <<< "$ehh < 10") )); then
        ehh="0$ehh"
    fi
    if (( $(bc <<< "$emm < 10") )); then
        emm="0$emm"
    fi
    if (( $(bc <<< "$ess < 10") )); then
        ess="0$ess"
    fi
    export end_time="$ehh:$emm:$ess"
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
        while getopts "a:t:f:d:s:q:i:o:x:y:S:" OPT; do
            case $OPT in
                a)
                    start_time="$OPTARG"
                    if [[ ${#start_time} -lt 10 ]]; then
                        echo "The start position must be given in the full hh:mm:ss.mss format"
                        exit 1
                    fi
                    ;;
                t)
                    duration="$OPTARG"
                    if [[ ${#duration} -lt 10 ]]; then
                        echo "The duration must be given in the full hh:mm:ss.mss format"
                        exit 1
                    fi
                    ;;
                f)
                    fps="$OPTARG"
                    ;;
                d)
                    dimensions="$OPTARG"
                    echo $dimensions
                    ;;
                s)
                    case $OPTARG in
                        bilinear|lanczos|bicubic)
                            scale_mode="$OPTARG"
                            ;;
                        *)
                            echo -e "Invalid scaling mode. Can be bilinear, lanczos, or bicubic."
                            exit 1
                            ;;
                    esac
                    ;;
                q)
                    quality="$OPTARG"
                    test $quality -lt 0 && quality=0
                    test $quality -gt 63 && quality=63
                    ;;
                i)
                    input="$OPTARG"
                    ;;
                o)
                    output="$OPTARG"
                    if [[ "$output" != "${output%.webm}.webm" ]]; then
                        echo "Output must have the extension .webm"
                        exit 1
                    fi
                    ;;
                x)
                    inopts="$OPTARG"
                    ;;
                y)
                    outopts="$OPTARG"
                    ;;
                S)
                    subs_mode="$OPTARG"
                    ;;
                x|y)
                    echo "Option $OPT is not yet implemented."
                    exit 1
                    ;;
            esac
        done
esac

case ${subs_mode:-no} in
    no)
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" \
            -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -sn \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -t "${duration:-10:00:00.0}" -pass 1 -f webm -y /dev/null && \
            ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" \
            -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -sn \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -t "${duration:-10:00:00.00}" -pass 2 -y "$output"
        ;;
    hard)
        #infile_extension=$(echo "$input" | awk 'BEGIN{FS="."}{print $NF}')
        #calculate_end_time $start_time $duration

        #ffmpeg -ss "00:00:00.0" -i "$input" \
        #    -sn -vf "subtitles='$input'" \
        #    -t "$end_time" -y "${output%.$infile_extension}_hard-subs.$infile_extension"

        #ffmpeg -ss "${start_time:-00:00:00.0}" -i "${output%.webm}_hard-subs.$infile_extension" \
        #    -vf "fps=${fps:--1}" \
        #    -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
        #    -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
        #    -t "${duration:-10:00:00.0}" -pass 1 -f webm -y /dev/null && \
        #    ffmpeg -ss "${start_time:-00:00:00.0}" -i "${output%.webm}_hard-subs.$infile_extension" \
        #    -vf "fps=${fps:--1}" \
        #    -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
        #    -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
        #    -t "${duration:-10:00:00.00}" -pass 2 -y "$output"

        #rm "${output%.webm}_hard-subs.$infile_extension"

        ffmpeg -i "$input" \
            -vf "fps=${fps:--1}" \
            -sn -vf "subtitles='$input'" \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -ss "${start_time:-00:00:00.0}" -t "${duration:-10:00:00.0}" -pass 1 -f webm -y /dev/null && \
            ffmpeg -i "$input" \
            -vf "fps=${fps:--1}" \
            -sn \
            -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -ss "${start_time:-00:00:00.0}" -t "${duration:-10:00:00.00}" -pass 2 -y "$output"
        ;;
    soft)
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" \
            -sn -vf "subtitles='$input'" \
            -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -t "${duration:-10:00:00.0}" -pass 1 -f webm -y /dev/null && \
            ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" \
            -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -c:v libvpx-vp9 -b:v 0 -crf "${quality:-25}" \
            -t "${duration:-10:00:00.00}" -pass 2 -y "$output"
        ;;
esac

test -e "ffmpeg2pass-0.log" && rm "ffmpeg2pass-0.log"
