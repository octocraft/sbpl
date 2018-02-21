#!/bin/bash
set -eu

# Add sbpl to path
export PATH="$PWD/../bin:$PATH"

# Get Packages
sbpl

# Get Env Vars
eval "$(sbpl envvars)"

# Include Packages
export PATH="$sbpl_path_bin:$PATH"

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
