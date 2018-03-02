#!/bin/bash
set -eu

export sbpl_os="windows"
export sbpl_arch="386"
sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}'

export sbpl_os="linux"
export sbpl_arch="amd64"
sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}'
