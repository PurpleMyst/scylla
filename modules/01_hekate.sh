#!/usr/bin/env bash

echo_level 0 "Hekate"

if [ ! -x "$(command -v 7z)" ]; then
    echo_level 1 "7z binary not found, exiting"
    exit 1
fi

echo_level 1 "Downloading"
download_latest_assets Joonie86 hekate

echo_level 1 "Extracting"
7z -y x "*hekate*.7z" -o"$OUTPUT_DIR" > /dev/null

echo_level 1 "Creating KIP module dir"
mkdir "$OUTPUT_DIR/bootloader/kip-modules"

echo_level 1 "Adding config"
cp "$CONFIG_DIR/bootloader/hekate_ipl.ini" "$OUTPUT_DIR/bootloader/"
