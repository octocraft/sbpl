#!/usr/bin/env bats

@test "sbpl upgrade" {

    rm -f sbpl.sh
    rm -rf vendor

    export OS="linux"
    export ARCH="amd64"
    target="sbpl-master-${OS}-${ARCH}"

    # Get copy
    cp --dereference sbpl.sh.base sbpl.sh

    # Make copy unique
    printf "\n\n#%s\n" "$(uuidgen)" >> sbpl.sh

    # Hash
    hash1=$(sha1sum sbpl.sh)

    # Upgrade
    run ./sbpl.sh upgrade
    [ "$status" -eq 0 ]
    ! [ -z "$output" ]
       
    # Hash
    hash2=$(sha1sum sbpl.sh)

    # Check result
    [ "$hash1" != "$hash" ]
    run ./sbpl.sh version
    [ "$status" -eq 0 ]
 
    # Clean up
    rm sbpl.sh
    rm -rf vendor
}
