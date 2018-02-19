#!/usr/bin/env bats

@test "sbpl upgrade" {

    rm -rf vendor

    export OS="linux"
    export ARCH="amd64"
    target="sbpl-master"

    # Get copy
    cp --dereference sbpl.sh.base sbpl.sh

    # Pre-load package (get_package will be skipped) 
    
    # 1. Create dirs
    mkdir -p "vendor/tmp"
    mkdir -p "vendor/bin/$OS/$ARCH"
    mkdir -p "vendor/$OS/$ARCH/$target"   # <-- existens of this dir is checked by get_package
    
    # 2. Create files 
    pushd "vendor/$OS/$ARCH/$target" > /dev/null
    printf "echo test" > "sbpl.sh"
    chmod u+x "sbpl.sh"
    mkdir -p "bin"
    ln -fs "../sbpl.sh" "bin/sbpl"
    popd > /dev/null

    # 3. Create link in bin-dir
    ln -fs "../../../$OS/$ARCH/$target/bin/sbpl" "vendor/bin/$OS/$ARCH/sbpl"

    # Call Upgrade
    run ./sbpl.sh upgrade
    [ "$status" -eq 0 ]
    ! [ -z "$output" ]
       
    run ./sbpl.sh
    [ "$status" -eq 0 ]
    [ "$output" = "test" ]
 
    # Clean up
    rm sbpl.sh
    rm -rf vendor
}
