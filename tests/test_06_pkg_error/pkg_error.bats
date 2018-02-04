#!/usr/bin/env bats

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
}

@test "sbpl_get wrong" {

    run ./sbpl.sh

    echo "status $status" 1>&2
    echo "output $output" 1>&2

    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Unknown option wrong" ]
    [ "${lines[1]}" = "Usage: sbpl_get 'target'" ]
}
