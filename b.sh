#!/bin/bash

# script to build AFL++ itself
export PREFIX=$HOME/.local
export CC=clang-15
export CXX=clang++-15
export LLVM_CONFIG=llvm-config-15
make all -j16
make install