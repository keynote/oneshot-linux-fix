#!/bin/bash

mkdir -p "removed_libs"
for file in *.so*; do
  if [[ "$file" = "libSDL2"* ]]; then continue; fi
  if test -e "/usr/lib32/$file" -o -e "/usr/lib64/$file"; then
    mv $file "removed_libs"
    echo "moved $file"
  fi
done
