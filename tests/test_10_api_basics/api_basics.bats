#!/usr/bin/env bats

function curl () {
    export TEST_PACKGE="package/test"
    ./sbpl_mock_curl.bash $@
}

function test_sbpl_mock_curl () {
    export TEST_EXPECTED_URL="test-0.0.0"
    export -f curl
    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]
    [ -d "vendor/$TEST_EXPECTED_URL" ]
}

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
}

@test "set OS/ARCH - windows/amd64" {

    export OS=windows
    export ARCH=amd64
    test_sbpl_mock_curl
}

@test "set OS/ARCH - linux/x86" {
 
    export OS=linux
    export ARCH=x86
    test_sbpl_mock_curl
}

@test "set OS/ARCH - android/arm" {

    export OS=android
    export ARCH=arm
    test_sbpl_mock_curl
}

@test "sbpl update" {

    export OS=linux
    export ARCH=arm
    test_sbpl_mock_curl "update"    
}

