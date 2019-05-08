#!/usr/bin/env bash
log-info "sys-netcheat"

log-info "Downloading assets"
download_latest_assets jakibaki sys-netcheat

log-info "Moving sys-netcheat.kip"
cp sys-netcheat.kip "$OUTPUT_DIR/atmosphere/kips/"
