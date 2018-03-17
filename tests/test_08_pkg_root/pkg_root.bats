#!/usr/bin/env bats

current_os="$(./sbpl.sh envvars _sbpl_os)"
current_arch="$(./sbpl.sh envvars _sbpl_arch)"

function curl () {
    ./sbpl_mock_curl.bash $@
}

export -f curl

function setup () {
    rm -rf vendor
}

function teardown () {
    rm -rf vendor
}

@test "move" {

    ./sbpl.sh get 'archive' 'name' 'version' 'package/root-test.tar' './'

    [   -f "vendor/$current_os/$current_arch/name-version/foo" ]
    [   -f "vendor/$current_os/$current_arch/name-version/test/bar" ]
    [ ! -d "vendor/$current_os/$current_arch/name-version/name-version" ]

    [ -f "vendor/bin/$current_os/$current_arch/foo" ]
    [ -f "vendor/bin/current/foo" ]
}

@test "don't move" {
    
    ./sbpl.sh get 'archive' 'name' 'master' 'package/root-test.tar' './name-version'

    [ ! -d "vendor/$current_os/$current_arch/name-version" ]
    [   -f "vendor/$current_os/$current_arch/name-master/name-version/foo" ]
    [   -f "vendor/$current_os/$current_arch/name-master/name-version/test/bar" ]

    [ -f "vendor/bin/$current_os/$current_arch/foo" ]
    [ -f "vendor/bin/current/foo" ]
}

