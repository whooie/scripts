#!/bin/bash

print-help(){
    echo -e "Frontend for gpg encryption/decryption and tar archiving."
    echo -e "\e[1mUsage:\e[0m \e[1mcypher\e[0m \e[4me\e[0m|\e[4mencrypt\e[0m \e[4mfile\e[0m [ \e[4mkey.txt\e[0m ]                           : Encrypt file"
    echo -e "       \e[1mcypher\e[0m \e[4ma\e[0m|\e[4marchive\e[0m \e[4mfile/directory\e[0m \e[4marchive name\e[0m [ \e[4mkey.txt\e[0m ]    : Archive with tar before encrypting"
    echo -e "       \e[1mcypher\e[0m \e[4mz\e[0m|\e[4mzip\e[0m \e[4mfile/directory\e[0m \e[4marchive name\e[0m [ \e[4mkey.txt\e[0m ]        : Archive and compress with tar and gzip before encrypting"
    echo -e "       \e[1mcypher\e[0m \e[4md\e[0m|\e[4mdecrypt\e[0m \e[4mfile.aes\e[0m \e[4mkey.txt\e[0m                           : Decrypt file"
    echo -e "       \e[1mcypher\e[0m \e[4mx\e[0m|\e[4mextract\e[0m \e[4mfile.aes\e[0m \e[4mkey.txt\e[0m                           : Decrypt file before extracting with tar"
    echo -e "       \e[1mcypher\e[0m \e[4mgd|gdegrypt\e[0m \e[4mfile.aes\e[0m [ \e[4moutput filename\e[0m ]             : Decrypt with gpg keyring"
    echo -e "       \e[1mcypher\e[0m \e[4mgx|gextract\e[0m \e[4mfile.aes\e[0m [ \e[4moutput filename\e[0m ]             : Decrypt with gpg keyring and extract with tar"
    echo -e "       \e[1mcypher\e[0m \e[4mg|gen-key\e[0m [ \e[4mkey name\e[0m ]                               : Generate a key"
    echo -e "       \e[1mcypher\e[0m [ h|-h|--help ]                                      : Display this text"
}

case $1 in
    -h|--help|h)
        print-help
        exit 0
        ;;
    "")
        print-help
        exit 1
        ;;
    archive|a)
        case $4 in
            "")
                filename="${3%.*}"
                echo "No key provided. Generating $filename-key.txt... "
                head --bytes 2048 /dev/urandom | base64 --wrap 0 >"$filename-key.txt"
                echo "Creating and encrypting $3 from $2 using $filename-key.txt... "
                tar -c "$2" | gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$filename-key.txt" >"$3.aes"
                ;;
            *)
                echo "Key $4 provided. Creating and encrypting $3 from $2 using $4... "
                tar -c "$2" | gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$4" >"$3.aes"
                ;;
        esac
        ;;
    zip|z)
        case $4 in
            "")
                filename="${3%.*}"
                echo "No key provided. Generating $filename-key.txt... "
                head --bytes 2048 /dev/urandom | base64 --wrap 0 >"$filename-key.txt"
                echo "Creating and encrypting $3 from $2 using $filename-key.txt... "
                tar -cz "$2" | gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$filename-key.txt" >"$3.aes"
                ;;
            *)
                echo "Key $4 provided. Creating and encrypting $3 from $2 using $4... "
                tar -cz "$2" | gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$4" >"$3.aes"
                ;;
        esac
        ;;
    encrypt|e)
        case $3 in
            "")
                filename="${2%.*}"
                echo "No key provided. Generating $filename-key.txt... "
                head --bytes 2048 /dev/urandom | base64 --wrap 0 >"$filename-key.txt"
                echo "Encrypting $2 using $filename-key.txt... "
                gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$filename-key.txt" <"$2" >"$2.aes"
                ;;
            *)
                echo "Key $3 provided. Encrypting $2 using $3... "
                gpg --symmetric --pinentry-mode loopback --passphrase-fd 3 3<"$3" <"$2" >"$2.aes"
                ;;
        esac
        ;;
    decrypt|d)
        case $3 in
            "")
                echo "No key provided."
                print-help
                exit 1
                ;;
            *)
                filename="${2%.encrypted}"
                filename="${filename%.aes}"
                echo "Key $3 provided. Decrypting $2 using $3... "
                gpg --decrypt --pinentry-mode loopback --passphrase-fd 3 3<"$3" <"$2" >"$filename"
                ;;
        esac
        ;;
    extract|x)
        case $3 in
            "")
                echo "No key provided."
                print-help
                exit 1
                ;;
            *)
                filename="${2%.encrypted}"
                filename="${filename%.aes}"
                echo "Key $3 provided. Decrypting $2 using $3 and unpacking... "
                gpg --decrypt --pinentry-mode loopback --passphrase-fd 3 3<"$3" <"$2" | tar -x
                ;;
        esac
        ;;
    gdecrypt|gd)
        outfile="${3:-${2%.aes}}"
        echo "Decrypting $2 to $outfile... "
        gpg --decrypt "$2" > "$outfile"
        ;;
    gextract|gx)
        outfile="${3:-${2%.aes}}"
        echo "Decrypting and unpacking $2 to $outfile... "
        gpg --decrypt "$2" | tar -x
        ;;
    g|gen-key)
        echo "Generating ${2:-unamed-key.txt}..."
        head --bytes 2048 /dev/urandom | base64 --wrap 0 >"${2:-unamed-key.txt}"
        ;;
    *)
        print-help
        exit 1
        ;;
esac
