#!/usr/bin/env bats

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
}

@test "sbpl_get usage" {

    run ./sbpl.sh
    [ "$status" -eq 2 ]
    echo "outpit: $output" 1>&2

    [ "${lines[0]}" = "Usage: sbpl_get 'target'" ]
    [ "${lines[1]}" = "file    'name' 'version'    'url'" ]
    [ "${lines[2]}" = "archive 'name' 'version'    'url' 'bin_dir'" ]
    [ "${lines[3]}" = "git     'name' 'branch/tag' 'url' 'bin_dir'" ]

}

