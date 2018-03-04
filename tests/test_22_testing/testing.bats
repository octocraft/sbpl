#!/usr/bin/env bats

function teardown () {
    rm -rf vendor
}

@test "testing" {
    
    # download package
    ./sbpl.sh test

    # run tests again
    run ./sbpl.sh test
    [ "$status" -eq 0 ] 
    [ "$output" = "$(< "output.diff")" ]
}

