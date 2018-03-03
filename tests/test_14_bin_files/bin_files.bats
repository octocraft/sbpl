#!/usr/bin/env bats

function curl () {
    export TEST_PACKGE="package/bin-test"
    ./sbpl_mock_curl.bash $@
}

export -f curl

function sbpl-pkg () {
    printf "%s\n%s\n\n" "#!/bin/bash" "set -eu" > sbpl-pkg.sh
    printf "%s\n" "sbpl_get 'archive' 'bin-test' 'version' 'url.tar' '$1'" >> sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
    rm -f sbpl-pkg.*
}

export sbpl_os="linux"
export sbpl_arch="amd64"

@test "file" {

    sbpl-pkg "file/foo"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
}

@test "link" {

    sbpl-pkg "link/foo"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
}

@test "file+link" {

    sbpl-pkg "file+link"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
    [ -f "vendor/bin/$sbpl_os/$sbpl_arch/bar" ]
}

@test "filter include" {

    sbpl-pkg "mixed/*.sh"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
    [   -f "vendor/bin/$sbpl_os/$sbpl_arch/foo.sh" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/bar" ]
    [   -f "vendor/bin/$sbpl_os/$sbpl_arch/bar.sh" ]

}

@test "filter exclude" {
    skip
    sbpl-pkg "mixed/!(*.sh)"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [   -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo.sh" ]
    [   -f "vendor/bin/$sbpl_os/$sbpl_arch/bar" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/bar.sh" ]

}

@test "empty" {

    sbpl-pkg ""

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ] 
}

@test "basedir" {

    sbpl-pkg "./"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [   -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
}

@test "no-x-file" {

    sbpl-pkg "no-x/foo"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ -x "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
}

@test "no-x-dir" {

    sbpl-pkg "no-x"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo.sh" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/bar" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/bar.sh" ]
}

@test "nox-x-filter" {

    sbpl-pkg "no-x/*.sh"

    run ./sbpl.sh $@
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2

    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/foo" ]
    [   -x "vendor/bin/$sbpl_os/$sbpl_arch/foo.sh" ]
    [ ! -f "vendor/bin/$sbpl_os/$sbpl_arch/bar" ]
    [   -x "vendor/bin/$sbpl_os/$sbpl_arch/bar.sh" ]

}


