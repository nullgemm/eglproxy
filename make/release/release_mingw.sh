#!/bin/bash

# get into the right folder
cd "$(dirname "$0")"
cd ../..

tag=$(git tag | tail -n 1)
release=eglproxy_bin_$tag

# generate dynamic libraries
mkdir -p "$release/lib/mingw"
make -f makefile_mingw clean
make -f makefile_mingw
cp bin/* "$release/lib/mingw/"

# generate EGL headers
mkdir -p "$release/include"
cp -r inc/* $release/include/
