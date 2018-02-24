#!/usr/bin/env bats

export OS="linux"
export ARCH="amd64"

function curl () {
    export TEST_PACKGE="package/test"
    ./sbpl_mock_curl.bash $@
}

export -f curl

@test "download file" {

    rm -rf vendor
    
    run ./sbpl.sh
    
    [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]    
}

@test "dont download file" {

    rm "vendor/$OS/$ARCH/test-0.0.0/test"

    run ./sbpl.sh
    [ "$status" -eq 0 ]

    ! [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]
}

@test "download file after clean" {

    ./sbpl.sh clean
    ! [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]

    run ./sbpl.sh

    [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]

    rm -rf vendor
}

