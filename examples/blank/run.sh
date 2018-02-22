#!/bin/bash

# Get Packages
./sbpl.sh

# Include Packages
export PATH="$(./sbpl.sh envvars sbpl_path_bin):$PATH"

# Execute
# Place your command here. All depenencies will be available
