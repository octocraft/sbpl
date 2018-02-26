#!/usr/bin/env bats

function curl () {
    export TEST_PACKGE="package/test"
    ./sbpl_mock_curl.bash $@
}

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}
    
@test "set OS/ARCH - mixed" {

    export TEST_EXPECTED_URL="test-0.0.0"
    export -f curl
    run ./sbpl.sh $@
    echo "status: $status" 1>&2
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]
    [ -d "vendor/windows/386/$TEST_EXPECTED_URL" ]
    [ -d "vendor/linux/amd64/$TEST_EXPECTED_URL" ]

}

