#!/usr/bin/env bats

target="sbpl-master"

export OS="linux"
export ARCH="amd64"
export LC_NUMERIC="en_US.UTF-8"

@test "archive" {

    pushd "target/archive" > /dev/null

    rm -rf vendor

    # Get Package
    output=$(./sbpl.sh | col -bp | diff target.log -)
    [ "$?" -eq 0 ]
    [ "${PIPESTATUS[0]}" -eq 0 ] 
 
    # Check data
    [ -f "vendor/$target/$target/bin/sbpl" ]
    [ -f "vendor/bin/sbpl" ]
    run ./vendor/bin/sbpl version
    [ "$status" -eq 0 ]
    
    # Do not re-download package
    run ./sbpl.sh
    [ "$status" -eq 0 ]
    [ -z "$output" ]

    rm -rf vendor
    
    popd > /dev/null
}

@test "git" {

    pushd "target/git" > /dev/null

    rm -rf vendor
    run ./sbpl.sh
    [ "$status" -eq 0 ]
    run ./vendor/bin/sbpl version
    [ "$status" -eq 0 ]
    [ -f "vendor/$target/bin/sbpl" ]

    rm -rf vendor

    popd > /dev/null
}

@test "file" {

    pushd "target/file" > /dev/null

    rm -rf vendor
    run ./sbpl.sh
    [ "$status" -eq 0 ]
    run ./vendor/bin/sbpl version
    [ "$status" -eq 0 ]
    [ -f "vendor/$target/sbpl" ]

    rm -rf vendor

    popd > /dev/null
}

