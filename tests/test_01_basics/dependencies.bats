#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="linux"
export sbpl_arch="amd64"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 0 0 $2 0" > sbpl-pkg.sh
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

    sbpl-pkg "file" "file"

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Neither 'curl' nor 'wget' found" ]
}

@test "no zip (curl)" {

    function curl () {
        # do not fall back
        if [ "${4##*/}" = "archiver" ]; then exit 2; fi

        export TEST_PACKGE="package/test"
        ./sbpl_mock_curl.bash $@
    }

    export -f curl
    sbpl-pkg "archive" "archive.zip"

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Get package: linux/amd64/0-0" ]
    [ "${lines[1]}" = "No suitable tool to extract archive found" ]
    [ "${lines[2]}" = "Error while extracting 'vendor/tmp/linux/amd64/0-0.zip'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 2" ]
}

@test "no zip (wget)" {

    function wget () {
        # do not fall back
        if [ "${3##*/}" = "archiver" ]; then return 2; fi

        export TEST_PACKGE="package/test"
        ./sbpl_mock_curl.bash -fsSL "$4" -o "$3"
    }

    export -f wget
    sbpl-pkg "archive" "archive.zip"

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Get package: linux/amd64/0-0" ]
    [ "${lines[1]}" = "No suitable tool to extract archive found" ]
    [ "${lines[2]}" = "Error while extracting 'vendor/tmp/linux/amd64/0-0.zip'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 2" ]
}

@test "no git" {

    sbpl-pkg "git" "repo"

    ln -s $(command -v bsdtar) dependencies/bsdtar
    ln -s $(command -v curl) dependencies/curl

    run mock_path "/bin:$(pwd)/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Dependency 'git' not found" ]
}

