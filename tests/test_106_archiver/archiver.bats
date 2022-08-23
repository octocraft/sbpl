#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="windows"
export sbpl_arch="386"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get archive name version archive.$1 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

target="vendor/$sbpl_os/$sbpl_arch/name-version"

function setup () {
    mkdir -p dependencies
    ln -fs /bin/* dependencies
    rm -f dependencies/curl
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

function curl () {
    if [ "$2" = "archive.tar" ]; then
        _1="$1"; _2="package/link.tar"; shift 2;
        ./sbpl_mock_curl.bash $_1 $_2 $@
    elif [ "$2" = "archive.tar.gz" ]; then
        _1="$1"; _2="package/link.tar.gz"; shift 2;
        export MOCK_CURL_COMPRESS="gz"
        ./sbpl_mock_curl.bash $_1 $_2 $@
    elif [ "$2" = "archive.tar.xz" ]; then
        _1="$1"; _2="package/link.tar.xz"; shift 2;
        export MOCK_CURL_COMPRESS="xz"
        ./sbpl_mock_curl.bash $_1 $_2 $@
    else
        command -p curl $@
    fi
}

export -f curl

@test "archiver tar" {

    sbpl-pkg "tar"

    run mock_path "$PWD/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ "$(./$target/foo.sh bar)" = "bar" ]
    [ "$(./$target/bin/foo bar)" = "bar" ]
}

@test "archiver tar.gz" {

    ln -sf "$(command -v gzip)" dependencies/gzip

    sbpl-pkg "tar.gz"

    run mock_path "$PWD/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ "$(./$target/foo.sh bar)" = "bar" ]
    [ "$(./$target/bin/foo bar)" = "bar" ]
}

@test "archiver tar.xz" {

    ln -sf "$(command -v xz)" dependencies/xz

    sbpl-pkg "tar.xz"

    run mock_path "$PWD/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ "$(./$target/foo.sh bar)" = "bar" ]
    [ "$(./$target/bin/foo bar)" = "bar" ]
}
