#!/bin/bash

# script to build target with customized afl
# usage: 
# /path/to/aflb.sh ./configure --disable-shared
# /path/to/aflb.sh make

export CC=afl-clang-fast
export CXX=afl-clang-fast++
export LD=afl-clang-fast
export CFLAGS="-g -fno-inline"  # no-inline to avoid transformation of function code
export CXXFLAGS="-g -fno-inline"
export AFL_DEBUG=1
export AFL_USE_ASAN=1
export AFL_LLVM_INSTRUMENT=classic  # used only when compiling targets, disabled when ./configure

$*
