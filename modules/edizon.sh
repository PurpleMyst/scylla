#!/usr/bin/env bash

log-info "EdiZon"

check_devkitpro_packages switch-dev switch-portlibs switch-freetype

log-info "Cloning WerWolv/EdiZon"
git clone "$QUIET_FLAG" https://github.com/WerWolv/EdiZon || die "Could not clone WerWolv/EdiZon"
cd EdiZon || die "EdiZon directory pulled out from under our feet!"

# HACK: The commit specified here does not compile, but the one three commits
# before does. The author has said that the bug will probably be fixed in the
# next commit.
if [ "$(git rev-parse HEAD)" == "61723064fc2e55549827b69bcd190b82cca884a9" ]; then
    git checkout "$QUIET_FLAG" HEAD~3
fi

commit=$(git rev-parse HEAD)

mkdir -p "$CACHE_DIR/edizon" || die "Could not create EdiZon cache directory"
if [ -e "$CACHE_DIR/edizon/commit.txt" ] && [ "$(cat "$CACHE_DIR/edizon/commit.txt")" == "$commit" ]; then
    log-info "Using cached EdiZon.nro"
else
    if [ -x "$(command -v nproc)" ]; then
        make_jobs=$(nproc)
    elif [ "$(uname)" == "Darwin" ]; then
        make_jobs=$(sysctl -n hw.physicalcpu)
    else
        make_jobs=1
    fi

    # We utilize only half of the cores because EdiZon is written in C++, a
    # language that's quite hard to compile: on my machine with eight logical cores
    # using all of them to compile absolutely kills it.
    if [ "$make_jobs" -gt 1 ]; then
        make_jobs=$((make_jobs / 2))
    fi

    if [ -n "$QUIET_FLAG" ]; then
        MAKE_STDOUT="/dev/null"
    else
        MAKE_STDOUT="/dev/stdout"
    fi

    log-info "Compiliing EdiZon.nro"
    make -j$make_jobs &> "$MAKE_STDOUT" || die "Could not compile EdiZon.nro"

    log-info "Caching EdiZon.nro"
    cp out/EdiZon.nro "$CACHE_DIR/edizon/"
    echo "$commit" > "$CACHE_DIR/edizon/commit.txt"
fi

log-info "Moving EdiZon.nro"
mkdir -p "$OUTPUT_DIR/switch/EdiZon"
cp "$CACHE_DIR/edizon/EdiZon.nro" "$OUTPUT_DIR/switch/EdiZon/" || die "Could not move EdiZon.nro"

log-info "Cloning WerWolv/EdiZon_CheatsConfigsAndScripts"
git clone "$QUIET_FLAG" https://github.com/WerWolv/EdiZon_CheatsConfigsAndScripts || die "Could not clone WerWolv/EdiZon_CheatsConfigsAndScripts"

log-info "Copying Confings & Scripts"
mkdir -p "$OUTPUT_DIR/switch/EdiZon/editor/scripts/"
cp -r EdiZon_CheatsConfigsAndScripts/Configs/* "$OUTPUT_DIR/switch/EdiZon/editor/"
cp -r EdiZon_CheatsConfigsAndScripts/Scripts/* "$OUTPUT_DIR/switch/EdiZon/editor/scripts/"

log-info "Copying Cheats"
cp -r EdiZon_CheatsConfigsAndScripts/Cheats/* "$OUTPUT_DIR/atmosphere/titles/"
