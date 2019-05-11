#!/usr/bin/env bash

log-info "Hekate"

if [ ! -x "$(command -v 7z)" ]; then
    die "7z binary not found, exiting"
fi

log-info "Downloading assets"
download_latest_assets Joonie86 hekate

if [ -n "$VERBOSE" ]; then
    SVNZ_STDOUT="/dev/stdout"
else
    SVNZ_STDOUT="/dev/null"
fi

log-info "Extracting *hekate*.7z"
7z -y x "*hekate*.7z" -o"$OUTPUT_DIR" > $SVNZ_STDOUT || die "Could not extract *hekate*.7z"
