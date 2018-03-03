#!/bin/bash
set -eu

sbpl_get 'archive' 'test' '0.0.0' '${name}-${version}-${sbpl_os}-${sbpl_arch}.tar'
