#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Include Packages
export PATH=$(pwd)/vendor/bin:$PATH

# Execute
# Place your command here. All depenencies will be available
