#!/bin/bash

export PATH="$1"
cmd="$2"
shift 2

$cmd $@
exit $?
