#!/bin/sh

if [ -z "$1" ]; then
    id=""
else
    id="-window $1"
fi

import $id "$HOME/Screenshot-$(date +%H-%M)".png
