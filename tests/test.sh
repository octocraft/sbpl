#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Include Packages
export PATH="$(./sbpl.sh envvars sbpl_path_bin):$PATH"

# Loop through test folders
for subdir in test*/; do 

    if [ -d "$subdir" ]; then
        
        printf "[${subdir%/}]\n"
        
        pushd "./$subdir" > /dev/null
            bats --tap .
        popd > /dev/null
    
        printf "\n"
    fi
done
