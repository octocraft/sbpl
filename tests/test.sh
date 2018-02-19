#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Include Packages
export PATH="$(pwd)/vendor/bin:$PATH"

for subdir in test*/; do 

    if [ -d "$subdir" ]; then
        
        printf "[${subdir%/}]\n"
        
        pushd "./$subdir" > /dev/null
            bats --tap .
        popd > /dev/null
    
        printf "\n"
    fi
done
