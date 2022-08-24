#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="linux"
export sbpl_arch="amd64"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 0 0 $2 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function arc () {
    exit 127
}

export -f arc

function setup () {
    mkdir -p dependencies
    ln -s "$(command -v cat)" dependencies/cat
    ln -s "$(command -v rm)" dependencies/rm
    ln -s "$(command -v mkdir)" dependencies/mkdir
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

@test "no curl and no wget" {
    
    rm -f dependencies/wget
    rm -f dependencies/curl

    sbpl-pkg "file" "file"

    run -127 mock_path "$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 127 ]
    [ "${lines[0]}" = "Neither 'curl' nor 'wget' found" ]
}

@test "no zip (curl)" {

    rm -f dependencies/unzip
    rm -f dependencies/wget

    function curl () {
        ./sbpl_mock_curl.bash $@
    };

    export -f curl

    sbpl-pkg "archive" "package/test.zip"

    run -127 mock_path "$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 127 ]
    [ "${lines[0]}" = "Get package: linux/amd64/0-0" ]
    [ "${lines[1]}" = "No suitable tool to extract archive found" ]
    [ "${lines[2]}" = "Error while extracting 'vendor/tmp/linux/amd64/0-0.zip'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 127" ]
}

@test "no zip (wget)" {

    rm -f dependencies/unzip
    rm -f dependencies/curl

    function wget () {
        ./sbpl_mock_curl.bash -fsSL "$4" -o "$3"
    };

    export -f wget

    sbpl-pkg "archive" "package/test.zip"

    run -127 mock_path "$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 127 ]
    [ "${lines[0]}" = "Get package: linux/amd64/0-0" ]
    [ "${lines[1]}" = "No suitable tool to extract archive found" ]
    [ "${lines[2]}" = "Error while extracting 'vendor/tmp/linux/amd64/0-0.zip'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 127" ]
}

@test "no git" {

    sbpl-pkg "git" "repo"

    run -127 mock_path "$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 127 ]
    [ "${lines[0]}" = "Dependency 'git' not found" ]
}
