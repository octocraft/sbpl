#!/bin/bash

printf "1..1\n"

if [ ! "$(cat foo)" = "bar" ]; then
    printf "not "
fi

printf "ok 1 - test\n"
