#!/usr/bin/env bats

function curl () {
    ./sbpl_mock_curl.bash $@
}

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

@test "sub package - download" {

    unset SBPL_NOSUBPKGS
    export -f curl

    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]
    [ -f "vendor/current/test/foo.sh" ]
    [ -f "vendor/current/sub/test" ]
}

@test "sub package - don't download" {

    export SBPL_NOSUBPKGS=true
    export -f curl

    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]
    [ -f "vendor/current/test/foo.sh" ]
    [ ! -f "vendor/current/sub/test" ]
}

