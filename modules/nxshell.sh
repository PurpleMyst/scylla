#!/usr/bin/env bash

log-info "NX-Shell"

log-info "Downloading assets"
download_latest_assets joel16 NX-Shell

log-info "Moving NX-Shell.nro"
cp NX-Shell.nro "$OUTPUT_DIR/switch/"
