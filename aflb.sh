#!/bin/bash

# script to build target with customized afl
# usage:
# /path/to/aflb.sh ./configure --disable-shared
# /path/to/aflb.sh make
# or just /path/to/aflb.sh

export CC=afl-clang-fast
export CXX=afl-clang-fast++
export LD=afl-clang-fast
export CFLAGS="-g -fno-inline $CFLAGS"  # no-inline to avoid transformation of function code
export CXXFLAGS="-g -fno-inline $CXXFLAGS"
export AFL_USE_ASAN=1
# export AFL_DEBUG=1  # may cause configure error, see https://github.com/AFLplusplus/AFLplusplus/issues/768
# export AFL_LLVM_INSTRUMENT=classic  # used only when compiling targets, disabled when ./configure

LLM_PROMPT_V="How likely is the given code snippet to cause vulnerabilities (e.g., logical issue, memory corruption, etc.)?"
LLM_PROMPT_C="How complex is the given code snippet (i.e., how hard is it to gain high test coverage by trying random arguments)?"
LLM_PROMPT_SUFFIX="Your answer should always start with an integer score from 0 to 100, without any other words. Always answer an integer even if the code is incomplete."
LLM_PROMPT_V_CN="所给代码片段导致漏洞（如逻辑问题、内存漏洞等）的可能性有多大？"
LLM_PROMPT_C_CN="所给代码片段有多复杂（即通过尝试随机参数获得高测试覆盖率有多难）？"
LLM_PROMPT_SUFFIX_CN="你的回答必须以一个 0 到 100 之间的整数得分开始，不能有任何其他字样。即使代码不完整，也一定要回答一个整数。"
export OPENAI_API_PROMPT="$LLM_PROMPT_V $LLM_PROMPT_SUFFIX"
# export OPENAI_API_BASE="https://api.endpoints.anyscale.com/v1"
# export OPENAI_API_MODEL=meta-llama/Llama-2-70b-chat-hf  # codellama/CodeLlama-34b-Instruct-hf

builddir="build"
if [ $# -eq 0 ]; then # no command given, automatically build
    # configure
    if [ -f "meson.build" ]; then
        meson $builddir
    elif [ -f "CMakeLists.txt" ]; then
        cmake -B $builddir -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo .
    elif [ -f "configure" ]; then
        ./configure --disable-shared --enable-static
    fi
    # build
    export AFL_LLVM_INSTRUMENT=classic
    export AFL_DEBUG=1
    if [ -d "$builddir" ]; then
        ninja -C $builddir -j 2
    elif [ -f "Makefile" ]; then
        bear -- make
    else
        echo "No build system found."
    fi
else
    # execute given command
    export AFL_LLVM_INSTRUMENT=classic  # used only when compiling targets, disabled when ./configure
    export AFL_DEBUG=1
    $*
fi
