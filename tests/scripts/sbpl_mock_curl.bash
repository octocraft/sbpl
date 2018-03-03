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
    # Create tar from folder
    command -p tar -C "$TEST_PACKGE" -cf "$dest" '.'
else
    # Empty tar
    command -p tar cvf "$dest" --files-from /dev/null
fi

exit 0
 
