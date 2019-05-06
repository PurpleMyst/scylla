#!/usr/bin/env bash
log-info "sys-netcheat"

log-info "Downloading assets"
download_latest_assets jakibaki sys-netcheat

log-info "Moving sys-netcheat.kip"
mv sys-netcheat.kip "$OUTPUT_DIR/bootloader/kip-modules/"
