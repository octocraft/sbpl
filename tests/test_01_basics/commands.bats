#!/usr/bin/env bats

@test "sbpl help" {

    run ./sbpl.sh help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "help    - print usage information" ]
    [ "${lines[1]}" = "update  - download packages" ]
    [ "${lines[2]}" = "upgrade - upgrade to latest sbpl version" ]
    [ "${lines[3]}" = "clean   - clear vendor dir" ]
    [ "${lines[4]}" = "version - print sbpl version information" ]
    [ "${lines[5]}" = "envvars - print vars used by sbpl. Pass a var name to filter the list" ]

}

@test "sbpl version" {

    run ./sbpl.sh version
    [ "$status" -eq 0 ]
    [ "$output" = "Simple Bash Package Loader - 1.0.0" ]
}

@test "sbpl usage" {

    run ./sbpl.sh unknownoption
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "./sbpl.sh: Unknown option unknownoption" ]
    [ "${lines[1]}" = "Use ./sbpl.sh help for help with command-line options," ]
    [ "${lines[2]}" = "or see the online docs at https://github.com/octocraft/sbpl" ]
}

@test "sbpl clean" {

    export OS="linux"
    export ARCH="amd64"

    # Create test file
    mkdir -p "vendor/$OS/$ARCH/test"
    echo "123" > "vendor/$OS/$ARCH/test/test.txt"

    # test the tester
    [ $(cat "vendor/$OS/$ARCH/test/test.txt") = "123" ]

    run ./sbpl.sh clean
    [ "$status" -eq 0 ]

    ! [ -f "vendor/$OS/$ARCH/test/test.txt" ]
    ! [ -d "vendor/$OS/$ARCH/test" ]

    unset OS
    unset ARCH
}

@test "sbpl envvars" {

    export OS="linux"
    export ARCH="amd64"

    run ./sbpl.sh envvars
    [ "$status" -eq 0 ]    

    unset OS
    unset ARCH
    eval "$output"

    # output
    [ "$OS"   = "linux" ]
    [ "$ARCH" = "amd64" ]
    [ "$sbpl_version" = "1.0.0" ]
    
    [ "$sbpl_dir_pkgs" = "vendor" ]
    [ "$sbpl_dir_bins" = "vendor/bin" ]
    [ "$sbpl_dir_tmps" = "vendor/tmp" ]
    
    [ "$sbpl_dir_pkg" = "vendor/linux/amd64" ]
    [ "$sbpl_dir_bin" = "vendor/bin/linux/amd64" ]
    [ "$sbpl_dir_tmp" = "vendor/tmp/linux/amd64" ]

    [ "$sbpl_path_pkg" = "$(pwd)/vendor/linux/amd64" ]
    [ "$sbpl_path_bin" = "$(pwd)/vendor/bin/linux/amd64" ]
    [ "$sbpl_path_tmp" = "$(pwd)/vendor/tmp/linux/amd64" ]

    # envvars with filter
    function test_envvar_filter () {
        var_name="$1"
        if [ "$(eval 'echo $'"$var_name")" = "$(./sbpl.sh envvars "$var_name")" ]; then
            return 0
        else
            retrun 1
        fi
    }
    
    test_envvar_filter "OS"
    test_envvar_filter "ARCH"
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
