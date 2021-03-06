#!/usr/bin/env bats

export sbpl_os="linux"
export sbpl_arch="amd64"

function setup () {
    rm -rf vendor
    rm -f sbpl-pkg.sh*
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.sh*
}

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 'test' '0.0.0' 'package/test$2' './'" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

@test "error curl" {

    sbpl-pkg "file"

    function curl () {
        echo "CURL-TEST-ERROR" 1>&2
        exit 42
    }

    export -f curl

    run ./sbpl.sh
    echo "ouput: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 42 ]
    [ "${lines[0]}" = "Get package: $sbpl_os/$sbpl_arch/test-0.0.0" ]
    [ "${lines[1]}" = "CURL-TEST-ERROR" ]
    [ "${lines[2]}" = "Error while downloading 'package/test'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 42" ]

    unset curl
}

@test "error archive" {

    sbpl-pkg "archive" ".tar"

    function curl () {
        ./sbpl_mock_curl.bash $@
    }

    function tar () {
        echo "TAR-TEST-ERROR" 1>&2
        exit 43
    }

    export -f curl
    export -f tar

    run ./sbpl.sh
    echo "ouput: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 43 ]
    [ "${lines[0]}" = "Get package: $sbpl_os/$sbpl_arch/test-0.0.0" ]
    [ "${lines[1]}" = "TAR-TEST-ERROR" ]
    [ "${lines[2]}" = "No suitable tool to extract archive found" ]
    [ "${lines[3]}" = "Error while extracting 'vendor/tmp/linux/amd64/test-0.0.0.tar'" ]
    [ "${lines[4]}" = "'sbpl-pkg.sh' failed with status 43" ]
}

@test "error git clone" {

    sbpl-pkg "git"

    function git () {
        echo "GIT-CLONE-TEST-ERROR" 1>&2
        exit 44
    }

    export -f git

    run ./sbpl.sh
    echo "ouput: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 44 ]
    [ "${lines[0]}" = "Get package: $sbpl_os/$sbpl_arch/test-0.0.0" ]
    [ "${lines[1]}" = "GIT-CLONE-TEST-ERROR" ]
    [ "${lines[2]}" = "Error while cloning repo 'package/test'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 44" ]
}

@test "error git checkout" {

    sbpl-pkg "git"

    function git () {

        if [ "$1" = "clone" ]; then
            exit 0
        fi

        echo "GIT-CHECKOUT-TEST-ERROR" 1>&2
        exit 45
    }

    export -f git

    run ./sbpl.sh
    echo "ouput: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 45 ]
    [ "${lines[0]}" = "Get package: $sbpl_os/$sbpl_arch/test-0.0.0" ]
    [ "${lines[1]}" = "GIT-CHECKOUT-TEST-ERROR" ]
    [ "${lines[2]}" = "Error while checking out branch/tag '0.0.0'" ]
    [ "${lines[3]}" = "'sbpl-pkg.sh' failed with status 45" ]
}

