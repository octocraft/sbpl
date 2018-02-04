#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export OS="linux"
export ARCH="amd64"

function setup () {
    mkdir -p "vendor/0-0-linux-amd64"
    mkdir -p dependencies
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
}

@test "no curl" {

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'curl' not found" ]
}

@test "no bsdtar" {

    ln -s $(command -v curl) dependencies/curl    

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'bsdtar' not found" ]
}

@test "no git" {

    ln -s $(command -v bsdtar) dependencies/bsdtar
    ln -s $(command -v curl) dependencies/curl

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'git' not found" ]
}
