#!/usr/bin/env bash

log-info "Incognito"

log-info "Downloading assets"
download_latest_assets blawar incognito

log-info "Moving incognito.nro"
mkdir "$OUTPUT_DIR/switch/incognito"
cp incognito.nro "$OUTPUT_DIR/switch/incognito/"
