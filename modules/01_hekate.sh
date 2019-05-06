#!/usr/bin/env bash

log-info "Hekate"

if [ ! -x "$(command -v 7z)" ]; then
    die "7z binary not found, exiting"
fi

log-info "Downloading assets"
download_latest_assets Joonie86 hekate

log-info "Extracting *hekate*.7z"
7z -y x "*hekate*.7z" -o"$OUTPUT_DIR" || die "Could not extract *hekate*.7z"

log-info "Creating \$OUTPUT_DIR/bootloader/kip-modules"
mkdir "$OUTPUT_DIR/bootloader/kip-modules"

log-info "Adding \$OUTPUT_DIR/bootloader/hekate_ipl.ini"
cp "$CONFIG_DIR/bootloader/hekate_ipl.ini" "$OUTPUT_DIR/bootloader/"
