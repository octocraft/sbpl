#!/usr/bin/env bats

export SBPL_VER="$(cat ../data/sbpl_version)"

@test "sbpl help" {

    run ./sbpl.sh help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "help    - print usage information" ]
    [ "${lines[1]}" = "update  - download packages" ]
    [ "${lines[2]}" = "upgrade - upgrade to latest sbpl version" ]
    [ "${lines[3]}" = "clean   - clear vendor dir" ]
    [ "${lines[4]}" = "version - print sbpl version information" ]
    [ "${lines[5]}" = "envvars - print vars used by sbpl. Pass a var name to filter the list" ]
    [ "${lines[6]}" = "get     - download package" ]
}

@test "sbpl version" {

    run ./sbpl.sh version
    [ "$status" -eq 0 ]
    [ "$output" = "Simple Bash Package Loader - $SBPL_VER" ]
}

@test "sbpl usage" {

    run ./sbpl.sh unknownoption
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "./sbpl.sh: Unknown option unknownoption" ]
    [ "${lines[1]}" = "Use ./sbpl.sh help for help with command-line options," ]
    [ "${lines[2]}" = "or see the online docs at https://github.com/octocraft/sbpl" ]
}

@test "sbpl clean" {

    export sbpl_os="linux"
    export sbpl_arch="amd64"

    # Create test file
    mkdir -p "vendor/$sbpl_os/$sbpl_arch/test"
    echo "123" > "vendor/$sbpl_os/$sbpl_arch/test/test.txt"

    # test the tester
    [ $(cat "vendor/$sbpl_os/$sbpl_arch/test/test.txt") = "123" ]

    run ./sbpl.sh clean
    [ "$status" -eq 0 ]

    ! [ -f "vendor/$sbpl_os/$sbpl_arch/test/test.txt" ]
    ! [ -d "vendor/$sbpl_os/$sbpl_arch/test" ]

    unset sbpl_os
    unset sbpl_arch
}

@test "sbpl envvars" {

    export sbpl_os="generic-os"
    export sbpl_arch="generic-arch"

    run ./sbpl.sh envvars
    echo "output: $output" 1>&2
    [ "$status" -eq 0 ]

    unset sbpl_os
    unset sbpl_arch
    eval "$output"

    # output
    [ "$sbpl_os"   = "generic-os" ]
    [ "$sbpl_arch" = "generic-arch" ]

    [ ! -z ${_sbpl_os+x} ]
    [ ! "$sbpl_os"   = "$_sbpl_os" ]
    [ ! -z ${_sbpl_arch+x} ]
    [ ! "$sbpl_arch" = "$_sbpl_arch" ]

    [ "$sbpl_version" = "$SBPL_VER" ]

    [ "$sbpl_dir_pkgs" = "vendor" ]
    [ "$sbpl_dir_bins" = "vendor/bin" ]
    [ "$sbpl_dir_tmps" = "vendor/tmp" ]

    [ "$sbpl_dir_pkg" = "vendor/generic-os/generic-arch" ]
    [ "$sbpl_dir_bin" = "vendor/bin/generic-os/generic-arch" ]
    [ "$sbpl_dir_tmp" = "vendor/tmp/generic-os/generic-arch" ]

    [ "$sbpl_path_pkg" = "$(pwd)/vendor/generic-os/generic-arch" ]
    [ "$sbpl_path_bin" = "$(pwd)/vendor/bin/generic-os/generic-arch" ]
    [ "$sbpl_path_tmp" = "$(pwd)/vendor/tmp/generic-os/generic-arch" ]

    # envvars with filter
    function test_envvar_filter () {
        export sbpl_os
        export sbpl_arch

        var_name="$1"

        if [ "$(eval 'echo $'"$var_name")" = "$(./sbpl.sh envvars "$var_name")" ]; then
            return 0
        else
            retrun 1
        fi
    }

    test_envvar_filter "sbpl_os"
    test_envvar_filter "sbpl_arch"
    test_envvar_filter "sbpl_version"

    test_envvar_filter "sbpl_dir_pkgs"
    test_envvar_filter "sbpl_dir_bins"
    test_envvar_filter "sbpl_dir_tmps"

    test_envvar_filter "sbpl_dir_pkg"
    test_envvar_filter "sbpl_dir_bin"
    test_envvar_filter "sbpl_dir_tmp"

    test_envvar_filter "sbpl_path_pkg"
    test_envvar_filter "sbpl_path_bin"
    test_envvar_filter "sbpl_path_tmp"
}
