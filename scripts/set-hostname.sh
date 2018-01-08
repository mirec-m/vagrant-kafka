#!/bin/bash

if [ $# -gt 0 ]; then
    hostname "$1"
else
    echo "Usage: "$(basename $0)" <hostname>"
fi

