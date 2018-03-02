#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="linux"
export sbpl_arch="amd64"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 0 0 0 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function setup () {
    mkdir -p dependencies
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

@test "no curl and no wget" {

    sbpl-pkg "file"

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Neither 'curl' nor 'wget' found" ]
}

@test "no bsdtar (curl)" {

    sbpl-pkg "archive"

    ln -s $(command -v curl) dependencies/curl    

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Dependency 'bsdtar' not found" ]
}

@test "no bsdtar (wget)" {

    sbpl-pkg "archive"

    ln -s $(command -v wget) dependencies/curl

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Dependency 'bsdtar' not found" ]
}

@test "no git" {

    sbpl-pkg "git"

    ln -s $(command -v bsdtar) dependencies/bsdtar
    ln -s $(command -v curl) dependencies/curl

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Dependency 'git' not found" ]
}
