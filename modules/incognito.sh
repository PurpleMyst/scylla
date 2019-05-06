#!/usr/bin/env bash

echo_level 0 "Incognito"

echo_level 1 "Downloading"
download_latest_assets blawar incognito

echo_level 1 "Moving"
mkdir "$OUTPUT_DIR/switch/incognito"
mv incognito.nro "$OUTPUT_DIR/switch/incognito/"
