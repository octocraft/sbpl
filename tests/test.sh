#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Get Env Vars
eval "$(./sbpl.sh envvars)"

# Include Packages
export PATH="$sbpl_path_bin:$PATH"

for subdir in test*/; do 

    if [ -d "$subdir" ]; then
        
        printf "[${subdir%/}]\n"
        
        pushd "./$subdir" > /dev/null
            bats --tap .
        popd > /dev/null
    
        printf "\n"
    fi
done
