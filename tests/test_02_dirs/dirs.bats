#!/usr/bin/env bats

function bsdtar () {
    $BATS_TEST_DIRNAME/sbpl_mock_bsdtar.bash $@
}

function curl () {
    $BATS_TEST_DIRNAME/sbpl_mock_curl.bash $@
}

export OS=""
export ARCH=""
export target="test-0.0.0-${OS}-${ARCH}"
export -f bsdtar
export -f curl
export BATS_TEST_DIRNAME

function setup () {
    rm -rf parent/vendor
}

function teardown () {
    rm -rf parent/vendor
}

@test "parent" {
    
    run ./parent/sbpl.sh
    [ "$?" -eq 0 ]
    echo "output: $output"

    [ -d "parent/vendor/$target" ]
    ! [ -d "vendor" ]
    [ "$(./parent/vendor/bin/test)" = "test" ]

}

@test "base" {
    
    pushd "parent" > /dev/null

    run ./sbpl.sh
    [ "$status" -eq 0 ]

    [ -d "vendor/$target" ]
    ! [ -d "../vendor" ]

    popd > /dev/null
}

@test "child" {
    
    pushd "parent/child" > /dev/null

    run ./../sbpl.sh
    [ "$status" -eq 0 ]    

    [ -d "../vendor/$target" ]
    ! [ -d "vendor" ]

    popd > /dev/null
}

