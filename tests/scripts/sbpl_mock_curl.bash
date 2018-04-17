set -eu

url="$2"
dest="$4"

if [ -z ${MOCK_CURL_COMPRESS+x} ]; then
    curl_params="-cf"
else
    curl_params="-czf"
fi

if ! [ -z ${TEST_EXPECTED_URL+x} ]; then
    if ! [ "$url" == "$TEST_EXPECTED_URL" ]; then
        printf "Expected '$TEST_EXPECTED_URL', got '$url'\n" 2>&1
        exit 1;
    fi
fi

src="${url%%.*}"

if [ -d "$src" ]; then
    # Create tar from folder
    command -p tar -C "$src" $curl_params "$dest" '.'
else
    # Empty tar
    command -p tar $curl_params "$dest" --files-from /dev/null
fi

exit 0
 
