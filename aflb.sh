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
export OPENAI_API_BASE="https://api.endpoints.anyscale.com/v1"
export OPENAI_API_MODEL=meta-llama/Llama-2-70b-chat-hf
# export OPENAI_API_MODEL=codellama/CodeLlama-34b-Instruct-hf
export OPENAI_API_PROMPT="Give relative complexity score of following function in the form as an integer from 0 to 100. You should answer EXACTLY one integer with NO additional words as they cost me more money.\n"
export OPENAI_API_MAXLEN=4096

$*
