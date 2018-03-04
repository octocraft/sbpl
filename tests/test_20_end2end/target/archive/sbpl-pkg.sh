#!/bin/bash
set -eu

sbpl_get 'archive' 'sbpl' 'master' 'https://github.com/octocraft/${name}/archive/${version}.zip' 'bin'
