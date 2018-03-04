#!/usr/bin/env bats

@test "testing" {

    function bats () 
    {
        path=$(pwd)
        name=${path##*/}
        echo $name
        echo $@
    }

    export -f bats

    run ./sbpl.sh test
    
    [ "$status" -eq 0 ] 
    [ "$output" = "$(< "output.diff")" ]
}

