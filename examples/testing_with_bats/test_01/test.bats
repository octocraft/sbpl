#!/usr/bin/env bats

@test "output from test" {
    
    run ../foo
    [ "$status" -eq 0 ]
    [ "$output" = "foo" ]
}
