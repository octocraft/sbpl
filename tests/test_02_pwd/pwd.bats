#!/usr/bin/env bats

function tar () {
    $BATS_TEST_DIRNAME/sbpl_mock_tar.bash $@
}

function curl () {
    unset TEST_PACKGE
    $BATS_TEST_DIRNAME/sbpl_mock_curl.bash $@
}

export sbpl_os=""
export sbpl_arch=""
export target="test-0.0.0"
export -f tar
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
    echo "output: $output"
    echo "status: $status"
    [ "$?" -eq 0 ]
    [ -d "vendor/$target" ]
    [ "$(vendor/bin/test)" = "test" ]
}

