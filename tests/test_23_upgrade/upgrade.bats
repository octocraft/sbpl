#!/usr/bin/env bats

@test "sbpl upgrade" {

    rm -rf vendor

    # Get copy
    cp -L sbpl.sh.base sbpl.sh

    # Make copy unique
    sed -i 's/sbpl_version="0.4.0"/sbpl_version="0.0.0-test"/g' sbpl.sh
    
    # Test version
    run ./sbpl.sh envvars sbpl_version
    [ "$status" -eq 0 ]
    [ "$output" = "0.0.0-test" ]

    # Call Upgrade
    run ./sbpl.sh upgrade
    [ "$status" -eq 0 ]
    ! [ -z "$output" ]

    [ -f "vendor/bin/current/sbpl" ]
    [ -f "vendor/current/sbpl/sbpl" ]

    run ./sbpl.sh envvars sbpl_version
    [ "$status" -eq 0 ]
    [ ! "$output" = "0.0.0-test" ]

    # Clean up
    rm sbpl.sh
    rm -rf vendor
}
