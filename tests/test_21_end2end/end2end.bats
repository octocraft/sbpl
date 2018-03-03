#!/usr/bin/env bats

eval "$(./sbpl.sh envvars)"

@test "Get package: foo-1.0.0" {

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    # Get Package
    ./sbpl.sh
    [ "$?" -eq 0 ]

    # Check file
    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]

    # Check command
    [ "$(./vendor/bin/$sbpl_os/$sbpl_arch/foo)" = "{\"foo\": \"bar\"}" ]
}

@test "Get package: foo-1.0.0 (don't download)" {

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*

    # Register foo
    function foo () {
        echo "hello world"
    }

    export -f foo

    # Get Package (should not download anything)
    ./sbpl.sh
    [ "$?" -eq 0 ]

    # Check file
    ! [ -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]

    # Test the tester
    [ "$(foo)" = "hello world" ]

    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

