#!/usr/bin/env bats

@test "sbpl init" {

    rm -f sbpl-pkg.sh

    # Create pkg file
    run ./sbpl.sh init
    [ "$status" -eq 0 ]
    [ -z "$output" ]

    # Check if file exists and is executable
    [ -x "sbpl-pkg.sh" ]

    # Check if output matches template
    diff "sbpl-pkg.sh" "sbpl-pkg.sh.base"

    # Check if pkg is not overwritten
    run ./sbpl.sh init
    [ "$status" -eq 1 ]
    [ "$output" = "sbpl-pkg.sh already exists" ]

    # Clean up
    rm -rf vendor
    rm -f sbpl-pkg.sh
    rm -f sbpl-pkg.sh.lock
}

