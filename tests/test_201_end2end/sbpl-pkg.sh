#!/bin/bash
set -eu

if ! command -v 'foo'; then
    sbpl_get 'file' 'foo' '1.0.0' 'https://github.com/octocraft/foo/releases/download/v1.0.0/foo_${sbpl_os}_${sbpl_arch}${sbpl_win_ext}' './'
fi
