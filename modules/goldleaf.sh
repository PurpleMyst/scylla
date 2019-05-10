#!/usr/bin/env bash

log-info "Goldleaf"

log-info "Downloading assets"
download_latest_assets XorTroll Goldleaf

log-info "Moving Goldleaf.nro"
cp Goldleaf.nro "$OUTPUT_DIR/switch/"
