☃() {
    local name="" hash=false stdin=false url=false nextname=false nofiles=true

    upload() {
        local hash=$1 url=$2 name="$3" file="$4"
        if [ $url = true ]; then
            # Upload from URL
            ssh valkyrja "curl -s \"$file\" | /usr/local/bin/☃ $hash \"$name\""
        else
            # Upload from local file
            cat "$file" | lz4 | ssh valkyrja "lz4 -d | /usr/local/bin/☃ $hash \"$name\""
        fi
    }

    # Go through the parameter list
    while [ "$1" != "" ]; do
        case "$1" in
            -h | --hash)
                hash=true
                ;;

            -u | --url)
                url=true
                ;;

            -)
                stdin=true
                ;;

            -n | --name)
                nextname=true
                ;;

            *)
                if [ $nextname = true ]; then
                    name="$1"
                    nextname=false
                else
                    if [ -z "$name" ]; then
                        name=`basename "$1"`
                    fi

                    upload $hash $url "$name" "$1"
                    hash=false
                    url=false
                    name=""
                    nofiles=false
                fi
                ;;
        esac
        shift
    done

    if [ $stdin = true ] || [ $nofiles = true ]; then
        upload $hash false "$name" /dev/stdin
    fi
}
