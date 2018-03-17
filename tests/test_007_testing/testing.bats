#!/usr/bin/env bats

@test "no dir" {

    function bats () {
        return 0
    }

    export -f bats

    run ./sbpl.sh test

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "dirs" {

    mkdir "test1" "test2" "test3 3"

    function bats () {

        path=$(pwd)
        name=${path##*/}
        echo $name
        echo $@
    }

    export -f bats

    run ./sbpl.sh test
    
    [ "$status" -eq 0 ] 
    [ "$output" = "$(< "output.diff")" ]

    rm -r "test1" "test2" "test3 3"
}

