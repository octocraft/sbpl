#!/usr/bin/env bats

@test "output from test" {
    
    run ../test
    [ "$status" -eq 0 ]
    [ "$output" = "foo" ]
}
