#!/usr/bin/env bats

function curl () {
    export TEST_PACKGE="package/bin-test"
    ./sbpl_mock_curl.bash $@
}

export -f curl

function sbpl-pkg () {
    printf "%s\n%s\n\n" "#!/bin/bash" "set -eu" > sbpl-pkg.sh
    printf "%s\n" "sbpl_get 'archive' 'bin-test' 'version' 'url' '$1'" >> sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function setup () {
    rm -rf vendor
}

function teardown () {
#    rm -rf vendor
    rm -f sbpl-pkg.sh.lock*
}

export OS="linux"
export ARCH="amd64"

@test "file" {

    sbpl-pkg "file/foo"
    
    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$OS/$ARCH/foo" ]
}

@test "link" {

    sbpl-pkg "link/foo"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$OS/$ARCH/foo" ]
}

@test "file+link" {

    sbpl-pkg "file+link"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$OS/$ARCH/foo" ]
    [ -f "vendor/bin/$OS/$ARCH/bar" ]
}

@test "filter include" {
    
    sbpl-pkg "mixed/*.sh"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ ! -f "vendor/bin/$OS/$ARCH/foo" ]
    [   -f "vendor/bin/$OS/$ARCH/foo.sh" ]
    [ ! -f "vendor/bin/$OS/$ARCH/bar" ]
    [   -f "vendor/bin/$OS/$ARCH/bar.sh" ]

}

@test "filter exclude" {
    skip
    sbpl-pkg "mixed/!(*.sh)"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [   -f "vendor/bin/$OS/$ARCH/foo" ]
    [ ! -f "vendor/bin/$OS/$ARCH/foo.sh" ]
    [   -f "vendor/bin/$OS/$ARCH/bar" ]
    [ ! -f "vendor/bin/$OS/$ARCH/bar.sh" ]

}

