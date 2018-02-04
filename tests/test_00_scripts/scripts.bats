#!/usr/bin/env bats

function curl () {
    ./sbpl_mock_curl.bash $@
}

function bsdtar () {
    ./sbpl_mock_bsdtar.bash $@
}

function mock_path () {
    ./sbpl_mock_path.bash $@
}

@test "sbpl_mock_curl.bash" {

    unset TEST_PACKGE
    unset TEST_EXPECTED_URL

    target="test.zip"
    rm -f $target

    # Check if zip is created
    run curl 0 0 0 "$target"
    [ "$status" -eq 0 ]
    [ -f "$target" ]
    rm -f $target
    
    # Check if fails if url doesnt match
    export TEST_EXPECTED_URL="test-url"
    run curl 0 "wrong-url" 0 "$target"
    [ "$status" -eq 1 ]
    ! [ -f "$target" ]
    
    # Check if zip is created with correct url
    export TEST_EXPECTED_URL="test-url"
    run curl 0 "test-url" 0 "$target"
    [ "$status" -eq 0 ]
    [ -f "$target" ]
    rm -f $target    

    # Check if zip is created from folder
    export TEST_PACKGE="package/test"
    run curl 0 "test-url" 0 "$target"
    [ -f "$target" ]

    # Extract arhive
    rm -rf vendor
    mkdir -p vendor/test
    command -p bsdtar -xf "$target" -C "vendor/test"

    # run test script
    run ./vendor/test/test
    [ "$status" -eq 0 ]
    [ "$output" = "foo" ]

    rm -f $target
    rm -rf vendor
}

@test "sbpl_mock_bsdtar.bash" {

    name="foo"
    pkg="$name-0.0.0-andorid-arm"
    src="./$pkg.zip"
    base="bsdtartest"
    dst="$base/$pkg"

    unset TEST_PKG_BIN_DIR
    rm -rf $base
    mkdir -p "$dst"

    # Check if list of files is correct    
    run bsdtar tv "$src" -C "$dst" 
    [ "$status" -eq 0 ]
    echo "--- $output" 1>&2
    [ "$output" = "./foo" ] 
    ! [ -d "$dst" ] 

    # Check if file is extracted
    run bsdtar xvf "$src" -C "$dst"    
    echo "--- $output" 1>&2
    [ "$status" -eq 0 ]
    [ "$output" = "x ./foo" ]
    [ -d "$dst" ]
    [ -f "$dst/$name" ]
    
    # Check file
    run $dst/$name
    [ "$status" -eq 0 ]
    [ "$output" = "test" ]

    # Check with different bin dir
    export TEST_PKG_BIN_DIR="./bin/"
       
    rm -rf $base
    mkdir -p "$dst"
    run bsdtar xvf "$src" -C "$dst"

    # Check file
    run "$dst/bin/$name"
    [ "$status" -eq 0 ]
    [ "$output" = "test" ]

    # Clean up
    rm -rf "bsdtartest"
}

@test "sbpl_mock_path.bash" {

    # Create script which can be called
    printf "#!/bin/bash\n%s\n" 'echo "$PATH - $1"; exit $2' > "testpath.sh"
    chmod u+x "testpath.sh"
    
    # run script with different path
    run mock_path "/bin" "./testpath.sh" "hello" 0
    [ "$status" -eq 0 ]
    [ "$output" = "/bin - hello" ]

    run mock_path "/bin" "./testpath.sh" "hello" 1
    [ "$status" -eq 1 ]
    [ "$output" = "/bin - hello" ]

    # Clean up
    rm -f "testpath.sh"
}
