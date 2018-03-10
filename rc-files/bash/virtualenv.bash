#!/bin/bash

function v {
    [ "$1" ] && source ~/.virtualenvs/"$1"/bin/activate
    echo "$VIRTUAL_ENV"
}
