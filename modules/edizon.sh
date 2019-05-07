#!/usr/bin/env bash

log-info "EdiZon"

check_devkitpro_packages switch-dev switch-portlibs switch-freetype

log-info "Cloning WerWolv/EdiZon"
git clone https://github.com/WerWolv/EdiZon || die "Could not clone WerWolv/EdiZon"
cd EdiZon || die "EdiZon directory pulled out from under our feet!"

# HACK: The commit specified here does not compile, but the one three commits
# before does. The author has said that the bug will probably be fixed in the
# next commit.
if [ "$(git rev-parse HEAD)" == "61723064fc2e55549827b69bcd190b82cca884a9" ]; then
    git checkout HEAD~3
fi

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

log-info "Compiliing EdiZon.nro"
make -j$make_jobs || die "Could not compile EdiZon.nro"

log-info "Moving EdiZon.nro"
mkdir "$OUTPUT_DIR/switch/EdiZon"
cp out/EdiZon.nro "$OUTPUT_DIR/switch/EdiZon/" || die "Could not move EdiZon.nro"

log-info "Cloning WerWolv/EdiZon_CheatsConfigsAndScripts"
git clone https://github.com/WerWolv/EdiZon_CheatsConfigsAndScripts || die "Could not clone WerWolv/EdiZon_CheatsConfigsAndScripts"

log-info "Copying Confings & Scripts"
mkdir -p "$OUTPUT_DIR/EdiZon/editor/scripts/"
cp -r EdiZon_CheatsConfigsAndScripts/Configs/* "$OUTPUT_DIR/EdiZon/editor/"
cp -r EdiZon_CheatsConfigsAndScripts/Scripts/* "$OUTPUT_DIR/EdiZon/editor/scripts/"

log-info "Copying Cheats"
cp -r EdiZon_CheatsConfigsAndScripts/Cheats/* "$OUTPUT_DIR/atmosphere/titles/"
