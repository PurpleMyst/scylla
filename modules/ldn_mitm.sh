#!/usr/bin/env bash
log-info "ldn_mitm"

log-info "Downloading assets"
download_latest_assets spacemeowx2 ldn_mitm

log-info "Extracting ldn_mitm_*.zip"
unzip "$QUIET_FLAG" ldn_mitm_*.zip -d "$OUTPUT_DIR/"
