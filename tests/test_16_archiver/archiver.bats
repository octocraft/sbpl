#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="windows"
export sbpl_arch="386"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get '$1' 0 0 $2 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

@test "archiver" {

    function curl () {
        if [ "$2" = "archive.tar" ]; then
            export TEST_PACKGE="package/test"
            ./sbpl_mock_curl.bash $@
        else
            command -p curl $@
        fi
    }

    export -f curl

    sbpl-pkg "archive" "archive.tar"

    mkdir -p dependencies
    ln -s /bin/* dependencies
    rm -f dependencies/tar

    run mock_path "$PWD/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ -f "vendor/windows/386/0-0/test" ]
}

