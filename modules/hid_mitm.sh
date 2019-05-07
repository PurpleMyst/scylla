#!/usr/bin/env bash

log-info "hid_mitm"

log-info "Downloading assets"
download_latest_assets jakibaki hid-mitm

log-info "Extracting hid-mitm.zip"
unzip "$QUIET_FLAG" hid-mitm.zip -d "$OUTPUT_DIR/"
