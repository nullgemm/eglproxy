#!/bin/bash

# get into the right folder
cd "$(dirname "$0")"
cd ../..

tag=$(git tag | head -n 1)
release=eglproxy_bin_$tag

# generate dynamic libraries
mkdir -p "$release/lib/msvc"
make -f makefile_msvc clean
make -f makefile_msvc
cp bin/* "$release/lib/msvc/"

# generate EGL headers
mkdir -p "$release/include"
cp -r inc/* $release/include/
