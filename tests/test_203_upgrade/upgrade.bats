#!/usr/bin/env bats

export SBPL_VER="$(cat ../data/sbpl_version)"

@test "sbpl upgrade" {

    rm -rf vendor

    # Get unique copy
    cat sbpl.sh.base | sed -e "s/sbpl_version=\"$SBPL_VER\"/sbpl_version=\"0.0.0-test\"/g" > sbpl.sh
    chmod +x sbpl.sh
    
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
