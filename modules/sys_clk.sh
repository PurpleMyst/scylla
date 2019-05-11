#!/usr/bin/env bash

log-info "sys-clk"

log-info "Downloading assets"
download_latest_assets retronx-team sys-clk

log-info "Extracting sys-clk-*.zip"
quiet unzip sys-clk-*.zip -d "$OUTPUT_DIR/"

log-info "Removing /README.html"
rm "$OUTPUT_DIR/README.html"

log-info "Removing /config/log.flag"
rm "$OUTPUT_DIR/config/sys-clk/log.flag"
