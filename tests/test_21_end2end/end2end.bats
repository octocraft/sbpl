#!/usr/bin/env bats

@test "Get package: foo-1.0.0" {

    rm -rf vendor
    
    # Get Package
    ./sbpl.sh
    [ "$?" -eq 0 ]

    # Check file
    [ -f "vendor/bin/foo" ]

    # Check command
    [ "$(./vendor/bin/foo)" = "{\"foo\": \"bar\"}" ]
}

@test "Get package: foo-1.0.0 (don't download)" {

    rm -rf vendor

    # Register foo
    function foo () { 
        echo "hello world"
    }    

    export -f foo

    # Get Package (should not download anything)
    ./sbpl.sh
    [ "$?" -eq 0 ]

    # Check file
    ! [ -f "vendor/bin/foo" ]

    # Test the tester
    [ "$(foo)" = "hello world" ]

    rm -rf vendor
}
