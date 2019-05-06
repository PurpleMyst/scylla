#!/usr/bin/env bash

echo_level 0 "IPS Patches"

if [ ! -x "$(command -v pup)" ]; then
    echo_level 1 "Could not find pup, exiting"
    exit 1
fi

echo_level 1 "Downloading gbatemp thread"
gbatemp_thread=$(wget -O- "https://gbatemp.net/threads/i-heard-that-you-guys-need-some-sweet-patches-for-atmosphere.521164/")
href=$(pup ".attachmentInfo > .filename > a attr{href}" <<< "$gbatemp_thread")
patches_url="https://gbatemp.net/$href"

echo_level 1 "Downloading patches"
wget -O patches.zip "$patches_url"

echo_level 1 "Extracting"
unzip patches.zip -d patches
cp -r patches/*/atmosphere/* "$OUTPUT_DIR/atmosphere/"
