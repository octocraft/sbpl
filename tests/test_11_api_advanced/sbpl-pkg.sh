#!/bin/bash
set -eu

export OS="windows"
export ARCH="i386"
sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}'

export OS="linux"
export ARCH="amd64"
sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}'
