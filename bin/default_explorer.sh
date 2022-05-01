#!/bin/bash

f_winpath() {
  local wp="$@"

  if [ -z "$wp" -o "$wp" = "." ]; then
    wp=$(pwd)
  fi

  echo $(cygpath -w $wp)
}

wp=$(f_winpath "$@")

exec explorer.exe "$wp" > /dev/null 2>&1 &

