#!/usr/bin/env bats

function bsdtar () {
    $BATS_TEST_DIRNAME/sbpl_mock_bsdtar.bash $@
}

function curl () {
    $BATS_TEST_DIRNAME/sbpl_mock_curl.bash $@
}

export OS=""
export ARCH=""
export target="test-0.0.0"
export -f bsdtar
export -f curl
export BATS_TEST_DIRNAME
export PATH="$PWD/bin:$PATH"

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

@test "pwd" {
    
    run sbpl
    [ "$?" -eq 0 ]
    [ -d "vendor/$target" ]
    [ "$(vendor/bin/test)" = "test" ]
}

