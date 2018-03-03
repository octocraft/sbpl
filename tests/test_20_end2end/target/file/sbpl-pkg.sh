#!/bin/bash
set -eu

sbpl_get 'file' 'sbpl' 'master' 'https://raw.githubusercontent.com/octocraft/${name}/${version}/${name}.sh' './'
