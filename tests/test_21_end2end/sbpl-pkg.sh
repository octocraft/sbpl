#!/bin/bash
set -eu

if ! command -v 'foo'; then
    sbpl_get 'archive' 'foo' '1.0.0' 'https://github.com/octocraft/${name}/raw/v${version}/dist/${name}.zip' './bin/${OS}/${ARCH}'
fi
