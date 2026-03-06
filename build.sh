#!/usr/bin/env bash

rm -rf build
mkdir -p build

for version in 20 21 ; do

prefix=$(brew --prefix llvm@$version)

for is_dyn in 0 1 ; do
for with_l in 0 1 ; do

    name=minimal-llvm$version-dyn$is_dyn-l$with_l

    args=(
        "$prefix/bin/clang++"
        -I "$prefix/include"
        -o "build/$name"
    )

    if [[ $with_l == 1 ]] ; then
        args+=(
            "-Wl,-L,$prefix/lib/c++"
        )
    fi
    args+=(
        "-Wl,-t"
    )

    if [[ $is_dyn == 1 ]] ; then
        args+=(
            "$prefix/lib/libclang-cpp.dylib"
        )
    else
        args+=(
            "$prefix/lib/libclangAPINotes.a"
            "$prefix/lib/libclangAST.a"
            "$prefix/lib/libclangASTMatchers.a"
            "$prefix/lib/libclangAnalysis.a"
            "$prefix/lib/libclangBasic.a"
            "$prefix/lib/libclangDriver.a"
            "$prefix/lib/libclangEdit.a"
            "$prefix/lib/libclangFormat.a"
            "$prefix/lib/libclangFrontend.a"
            "$prefix/lib/libclangLex.a"
            "$prefix/lib/libclangParse.a"
            "$prefix/lib/libclangRewrite.a"
            "$prefix/lib/libclangSema.a"
            "$prefix/lib/libclangSerialization.a"
            "$prefix/lib/libclangSupport.a"
            "$prefix/lib/libclangTooling.a"
            "$prefix/lib/libclangToolingCore.a"
            "$prefix/lib/libclangToolingInclusions.a"
        )
    fi
    args+=(
        "$prefix/lib/libLLVM.dylib"
        minimal.cpp
    )

    (
        echo "${args[@]}"
        "${args[@]}" 2>&1 | sort 
    ) >build/$name.log

    echo $name
    build/$name

    echo

done
done
done
