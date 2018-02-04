set -eu

url="$2"
dest="$4"

if ! [ -z ${TEST_EXPECTED_URL+x} ]; then
    if ! [ "$url" == "$TEST_EXPECTED_URL" ]; then
        printf "Expected '$TEST_EXPECTED_URL', got '$url'\n" 2>&1
        exit 1;
    fi
fi

if ! [ -z ${TEST_PACKGE+x} ]; then
    # Create zip from folder
    bsdtar -C "$TEST_PACKGE" -acf "$dest" '.'   
else
    # Empty zip archive
    echo -e "\x50\x4B\x05\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" > $dest
fi

exit 0
 
