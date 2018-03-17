#!/usr/bin/env bats

function run_example () {

    dir=$1
    bin=$2
    shift 2

    cd ../../examples/$dir
    ./$bin $@    
    rm -rf vendor
}

@test "starter_fetch_sbpl" {
    run_example "starter_fetch_sbpl" "run.sh"
}

@test "starter_offline_sbpl" {
    run_example "starter_offline_sbpl" "run.sh"
}

@test "testing_with_bats" {
    run_example "testing_with_bats" "test.sh"
}

