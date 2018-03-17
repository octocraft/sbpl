#!/usr/bin/env bats

export sbpl_os="linux"
export sbpl_arch="amd64"

function curl () {
    ./sbpl_mock_curl.bash $@
}

export -f curl

@test "download pkg" {

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    run ./sbpl.sh
    [ -f "vendor/$sbpl_os/$sbpl_arch/test-0.0.0/test" ]
}

@test "dont download pkg" {

    rm "vendor/$sbpl_os/$sbpl_arch/test-0.0.0/test"

    run ./sbpl.sh
    ! [ -f "vendor/$sbpl_os/$sbpl_arch/test-0.0.0/test" ]
}

@test "download pkg after clean" {

    ./sbpl.sh clean
    ! [ -f "vendor/$sbpl_os/$sbpl_arch/test-0.0.0/test" ]

    run ./sbpl.sh
    [ -f "vendor/$sbpl_os/$sbpl_arch/test-0.0.0/test" ]
}

@test "remove pkg on error" {

    ./sbpl.sh clean

    function curl () {
        echo "Test Error" 1>&2
        exit 42
    }

    export -f curl

    run ./sbpl.sh
    echo "output: $output" 1>&2
    [ ! -d "vendor/$sbpl_os/$sbpl_arch/test-0.0.0" ]

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

