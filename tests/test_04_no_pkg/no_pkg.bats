#!/usr/bin/env bats

function teardown () {
    rm -rf vendor
}

@test "no sbpl-pkg.sh" {

    run ./sbpl.sh
    [ "$status" -eq 1 ]
    [ "$output" = "'sbpl-pkg.sh' not found. quit." ]
}

