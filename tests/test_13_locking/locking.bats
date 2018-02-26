#!/usr/bin/env bats

export OS="linux"
export ARCH="amd64"

function curl () {
    export TEST_PACKGE="package/test"
    ./sbpl_mock_curl.bash $@
}

export -f curl

function sbpl-pkg () {
    printf "%s\n%s\n\n" "#!/bin/bash" "set -eu" > sbpl-pkg.sh
    printf "%s\n" "sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}'" >> sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
} 

@test "download pkg" {

    # clean
    rm -rf vendor
    rm -f sbpl-pkg.sh
    rm -f sbpl-pkg.sh.lock
    
    # get pkg
    sbpl-pkg
    run ./sbpl.sh
    
    # check pkg
    [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]    
}

@test "dont download pkg" {
    
    # remove file from pkg
    rm -r "vendor/$OS/$ARCH/test-0.0.0"

    # re-run sbpl
    run ./sbpl.sh

    # check if file is still missing (no re-donwload)
    ! [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]
}

@test "dont download pkg (pkg new timestamp)" {
    
    # re-create pkg file
    sbpl-pkg

    # re-run sbpl
    run ./sbpl.sh
    
    # check if file is still missing (no re-donwload)
    ! [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]
}

@test "download pkg (new pkg content)" {

    # add content to pkg file
    printf "\n%s\n" "# Test" >> sbpl-pkg.sh

    # re-run sbpl
    run ./sbpl.sh

    # check pkg
    [ -f "vendor/$OS/$ARCH/test-0.0.0/test" ]    
}

@test "remove lock file on error" {

    # add content to pkg file
    printf "\n%s\n" "echo 'failed intentionally'; exit 42" >> sbpl-pkg.sh

    # re-run sbpl
    run ./sbpl.sh
    echo "status: $status"
    echo "output: $output"
    [ "$status" -eq 42 ]
    [ "${lines[0]}" = "failed intentionally" ]
    [ "${lines[1]}" = "'sbpl-pkg.sh' failed with status 42" ]

    # check pkg
    ! [ -f "sbpl-pkg.sh.lock" ]
}

@test "do not create lock file on error" {
    
    # re-run sbpl
    run ./sbpl.sh

    # check pkg
    ! [ -f "sbpl-pkg.sh.lock" ]

    # clean
    rm -rf vendor
    rm -f sbpl-pkg.sh*
}

