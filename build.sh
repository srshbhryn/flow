#!/usr/bin/env bash

dune fmt
dune build

DIR="./_build/default/bin/"

find "$DIR" -type f -name "*.exe" | while read -r file; do
  name=$(basename "$file")
  ln -s "$file" "$name"
done
