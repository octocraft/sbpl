#!/usr/bin/env bats

function mock_path () {
    ./sbpl_mock_path.bash $@
}

export sbpl_os="windows"
export sbpl_arch="386"

function sbpl-pkg () {
    printf "#!/bin/bash\n\nsbpl_get archive name version archive.$1 0" > sbpl-pkg.sh
    chmod u+x sbpl-pkg.sh
}

target="vendor/$sbpl_os/$sbpl_arch/name-version"

function teardown () {
    rm -rf vendor
    rm -rf dependencies
    rm -f sbpl-pkg.sh*
}

function curl () {
    if [ "${2%.*}" = "archive" ]; then
        _1="$1"; _2="package/link.tar"; shift 2;
        ./sbpl_mock_curl.bash $_1 $_2 $@
    else
        command -p curl $@
    fi
}

export -f curl

@test "archiver tar" {

    sbpl-pkg "tar"

    mkdir -p dependencies
    ln -s /bin/* dependencies
    rm -f dependencies/tar

    run mock_path "$PWD/dependencies" "./sbpl.sh" "update"
    echo "output: $output" 1>&2
    echo "status: $status" 1>&2
    [ "$status" -eq 0 ]

    [ "$(./$target/foo.sh bar)" = "bar" ]
    [ "$(./$target/bin/foo bar)" = "bar" ]

}

