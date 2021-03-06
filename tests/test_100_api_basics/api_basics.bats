#!/usr/bin/env bats

current_os="$(./sbpl.sh envvars _sbpl_os)"
current_arch="$(./sbpl.sh envvars _sbpl_arch)"

function curl () {
    ./sbpl_mock_curl.bash $@
}

function test_sbpl_mock_curl () {
    target="test-0.0.0"
    export TEST_EXPECTED_URL="package/test.tar"
    export -f curl
    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]

    [ -d "vendor/$sbpl_os/$sbpl_arch/$target" ]
    [ "$(readlink "vendor/current")" = "$current_os/$current_arch" ]
    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/test" ]
}

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

@test "set sbpl_os/sbpl_arch - windows/amd64" {

    export sbpl_os=windows
    export sbpl_arch=amd64
    test_sbpl_mock_curl
}

@test "set sbpl_os/sbpl_arch - linux/x86" {

    export sbpl_os=linux
    export sbpl_arch=x86
    test_sbpl_mock_curl
}

@test "set sbpl_os/sbpl_arch - android/arm" {

    export sbpl_os=android
    export sbpl_arch=arm
    test_sbpl_mock_curl
}

@test "sbpl update" {

    export sbpl_os=linux
    export sbpl_arch=arm
    test_sbpl_mock_curl "update"
}

@test "sbpl get" {
    export sbpl_os=linux
    export sbpl_arch=arm
    test_sbpl_mock_curl "get" "archive" "test" "0.0.0" "package/test.tar" "./"
}

