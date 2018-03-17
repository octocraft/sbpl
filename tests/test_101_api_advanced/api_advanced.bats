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

@test "set sbpl_os/sbpl_arch - mixed" {

    target="test-0.0.0"
    export TEST_EXPECTED_URL="package/test.tar"
    export -f curl
    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]
    [ -f "vendor/windows/386/$target/test" ]
    [ -f "vendor/linux/amd64/$target/test" ]
}

