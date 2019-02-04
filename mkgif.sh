#!/bin/bash

print-help() {
    echo -e "Frontend for ffmpeg to create gifs."
    echo -e "\e[1mUsage:\e[0m \e[1mmkgif\e[0m [ \e[4mopts\e[0m ] \e[1m-i\e[0m \e[4minput video\e[0m \e[1m-o\e[0m \e[4moutput gif\e[0m"
    echo -e "       \e[1mmkgif\e[0m [ -h ]"
    echo -e "\e[1mOptions:\e[0m"
    echo -e "  \e[1m-i\e[0m <\e[4mfile\e[0m>            Input video file."
    echo -e "  \e[1m-o\e[0m <\e[4mfile\e[0m>            Output gif file."
    echo -e "  \e[1m-a\e[0m <\e[4mhh\e[0m:\e[4mmm\e[0m:\e[4mss\e[0m.\e[4ms\e[0m>      Starting position. Defaults to \e[1m00:00:00.0\e[0m."
    echo -e "  \e[1m-t\e[0m <\e[4mhh\e[0m:\e[4mmm\e[0m:\e[4mss\e[0m:\e[4ms\e[0m>      Duration. Defaults to \e[1m10:00:00.0\e[0m."
    echo -e "  \e[1m-f\e[0m <\e[4mint\e[0m>             Framerate of the output. Use -1 to use the same framerate as the input."
    echo -e "                         Defaults to the input's framerate."
    echo -e "  \e[1m-d\e[0m <\e[4mwidth\e[0m:\e[4mheight\e[0m>    Dimensions of the output. Use -1 to use the same width or height as the"
    echo -e "                         input or a length which would preserve the input's aspect ratio. Defaults"
    echo -e "                         to the dimensions of the input. There is no syntax check here, so expect"
    echo -e "                         ffmpeg errors if something is wrong with this option."
    echo -e "  \e[1m-s\e[0m <\e[4mmode\e[0m>            Scaling mode. Can be \e[1mbilinear\e[0m, \e[1mlanczos\e[0m, or \e[1mbicubic\e[0m. Defaults to \e[1mlanczos\e[0m."
    echo -e "  \e[1m-S\e[0m <\e[4mmode\e[0m>            Stats mode to generate a color palette. Can be \e[1mdiff\e[0m or \e[1mfull\e[0m. Defaults to \e[1mfull\e[0m."
    echo -e "  \e[1m-D\e[0m <\e[4mmode\e[0m>            Dither mode. Can be \e[1mbayer1\e[0m, \e[1mbayer2\e[0m, \e[1mbayer3\e[0m, \e[1mfloyd_steinberg\e[0m, \e[1msierra2\e[0m,"
    echo -e "                         \e[1msierra2_4a\e[0m, or \e[1mnone\e[0m. Defaults to \e[1mbayer3\e[0m."
    echo -e "  \e[1m-b\e[0m                   Burn subtitles into output."
    #echo -e "  \e[1m-x\e[0m <\e[4mopts\e[0m>            Specify any extra ffmpeg input arguments. Syntax is not checked."
    #echo -e "  \e[1m-y\e[0m <\e[4mopts\e[0m>            Specift any extra ffmpeg output arguments. Syntax is not checked."
    echo -e "  \e[1m-P\e[0m                   Keep the color palette."
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
        while getopts "a:bt:f:d:s:S:D:Pi:o:x:y:" OPT; do
            case $OPT in
                a)
                    start_time="$OPTARG"
                    ;;
                t)
                    duration="$OPTARG"
                    ;;
                f)
                    fps="$OPTARG"
                    ;;
                d)
                    dimensions="$OPTARG"
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
                S)
                    case $OPTARG in
                        diff|full)
                            stats_mode="$OPTARG"
                            ;;
                        *)
                            echo -e "Invalid stats mode. Can be diff or full."
                            exit 1
                            ;;
                    esac
                    ;;
                D)
                    case $OPTARG in
                        bayer1|bayer2|bayer3)
                            dither_mode="bayer:bayer_scale=${OPTARG:5:1}"
                            ;;
                        floyd_steinberg|sierra2|sierra2_4a|none)
                            dither_mode="$OPTARG"
                            ;;
                        *)
                            echo -e "Invalid dither mode. Can be bayer1, bayer2, bayer3, floyd_steinberg, sierra2, sierra2_4a, or none."
                            exit 1
                            ;;
                    esac
                    ;;
                P)
                    keep_palette="true"
                    ;;
                i)
                    input="$OPTARG"
                    ;;
                o)
                    output="$OPTARG"
                    if [[ "$output" != "${output%.gif}.gif" ]]; then
                        echo "Output must have the extension .gif"
                        exit 1
                    fi
                    ;;
                x)
                    inopts="$OPTARG"
                    ;;
                y)
                    outopts="$OPTARG"
                    ;;
                b)
                    burn_subs="yes"
                    ;;
                x|y)
                    echo "Option $OPT is not yet implemented."
                    exit 1
                    ;;
            esac
        done
esac

palette="palette.png"

(test "$input" == "" || test "$output" == "") && (echo "Input and Output must be specified." && exit 1)

#ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
#    -vf "fps=${fps:--1}" -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
#    -vf "palettegen=stats_mode=${stats_mode:-full}" \
#    -t "${duration:-10:00:00.0}" -y "$palette"
#ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" -i "$palette" \
#    -lavfi "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos},paletteuse=dither=${dither_mode:-bayer:bayer_scale=3}" \
#    -t "${duration:-10:00:00.0}" -y "$output"

case ${burn_subs:-no} in
    yes)
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -vf "palettegen=stats_mode=${stats_mode:-full}" \
            -t "${duration:-10:00:00.0}" -y "$palette"
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" -i "$palette" \
            -lavfi "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos},paletteuse=dither=${dither_mode:-bayer:bayer_scale=3},subtitles='$input'" \
            -t "${duration:-10:00:00.0}" -y "$output"
        ;;
    no)
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" \
            -vf "fps=${fps:--1}" -vf "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos}" \
            -vf "palettegen=stats_mode=${stats_mode:-full}" \
            -t "${duration:-10:00:00.0}" -y "$palette"
        ffmpeg -ss "${start_time:-00:00:00.0}" -i "$input" -i "$palette" \
            -lavfi "scale=${dimensions:--1:-1}:flags=${scale_mode:-lanczos},paletteuse=dither=${dither_mode:-bayer:bayer_scale=3}" \
            -t "${duration:-10:00:00.0}" -y "$output"
        ;;
esac

test "$keep_palette" == "true" || (test -e "$palette" && rm "$palette")
