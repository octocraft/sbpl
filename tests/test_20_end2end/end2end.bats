#!/usr/bin/env bats

target="sbpl-master"

export sbpl_os="linux"
export sbpl_arch="amd64"
export LC_NUMERIC="en_US.UTF-8"

@test "archive" {

    pushd "target/archive" > /dev/null

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    # Get Package
    run ./sbpl.sh
    [ "$status" -eq 0 ]

    # Check data
    [ -f "vendor/$sbpl_os/$sbpl_arch/$target/bin/sbpl" ]
    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/sbpl" ]
    run ./vendor/bin/$sbpl_os/$sbpl_arch/sbpl version
    [ "$status" -eq 0 ]

    # Do not re-download package
    run ./sbpl.sh
    [ "$status" -eq 0 ]
    [ -z "$output" ]

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    popd > /dev/null
}

@test "git" {

    pushd "target/git" > /dev/null

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    run ./sbpl.sh
    [ "$status" -eq 0 ]
    run ./vendor/bin/$sbpl_os/$sbpl_arch/sbpl version
    [ "$status" -eq 0 ]
    [ -f "vendor/$sbpl_os/$sbpl_arch/$target/bin/sbpl" ]

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    popd > /dev/null
}

@test "file" {

    pushd "target/file" > /dev/null

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    run ./sbpl.sh
    [ "$status" -eq 0 ]
    run ./vendor/bin/$sbpl_os/$sbpl_arch/sbpl version
    [ "$status" -eq 0 ]
    [ -f "vendor/$sbpl_os/$sbpl_arch/$target/sbpl" ]

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    popd > /dev/null
}

