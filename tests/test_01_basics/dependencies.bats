#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export OS="linux"
export ARCH="amd64"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 0 0 0 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function setup () {
    mkdir -p "vendor/0-0-linux-amd64"
    mkdir -p dependencies
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh
}

@test "no curl" {

    sbpl-pkg "file"

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'curl' not found" ]
}

@test "no bsdtar" {

    sbpl-pkg "archive"

    ln -s $(command -v curl) dependencies/curl    

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'bsdtar' not found" ]
}

@test "no git" {

    sbpl-pkg "git"

    ln -s $(command -v bsdtar) dependencies/bsdtar
    ln -s $(command -v curl) dependencies/curl

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    
    [ "$status" -eq 2 ]
    [ "$output" = "Dependency 'git' not found" ]
}
