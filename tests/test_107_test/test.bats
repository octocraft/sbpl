#!/usr/bin/env bats

@test "sbpl test - command not found" {

    run ./sbpl.sh test . commandnotfound
    [ "$output" = "unknown command 'commandnotfound'" ]
}

@test "sbpl test - command" {

    run ./sbpl.sh test . echo foo
    echo "output: $output" 1>&2
    [ "${lines[0]}" = "[test_00_success]" ]
    [ "${lines[1]}" = "foo" ]
    [ "${lines[2]}" = "[test_01_fail]" ]
    [ "${lines[3]}" = "foo" ]
}

@test "sbpl test - script" {

    run ./sbpl.sh test . mytest.sh
    echo "output: $output" 1>&2
    [ "${lines[1]}" = "1..1" ]
    [ "${lines[2]}" = "ok 1 - test" ]
    [ "${lines[4]}" = "1..1" ]
    [ "${lines[5]}" = "not ok 1 - test" ]
}
