#!/usr/bin/env bash

dune fmt
dune build

DIR="./_build/default/bin/"

find "$DIR" -type f -name "*.exe" | while read -r file; do
  name=$(basename "$file")
  if [ ! -L "$name" ]; then
    ln -s "$file" "$name"
  fi
done
