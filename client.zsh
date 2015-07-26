☃() {
    local name="" hash=false stdin=false url=false nextname=false

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

    # If we use no parameter at all, just look at stdin
    if [ -z "$*" ]; then
        stdin=true
    fi

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
                fi
                ;;
        esac
        shift
    done

    if [ $stdin = true ]; then
        upload true false "" /dev/stdin
    fi
}
