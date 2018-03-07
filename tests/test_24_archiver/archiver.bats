#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

@test "archiver zip" {

    mkdir -p dependencies
    ln -s "$(command -v curl)" dependencies
    ln -s "$(command -v wget)" dependencies

    run mock_path "/bin:$PWD/dependencies" "./sbpl.sh" "get" "archive" "sbpl" "master" 'https://github.com/octocraft/${name}/archive/${version}.zip'
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ "$(./vendor/current/sbpl/sbpl.sh envvars sbpl_dir_pkgs)" = "vendor" ]
    [ "$(./vendor/current/sbpl/bin/sbpl envvars sbpl_dir_pkgs)" = "vendor" ]
}

