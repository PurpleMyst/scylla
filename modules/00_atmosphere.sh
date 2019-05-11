#!/usr/bin/env bash
log-info "Atmosphere"

log-info "Downloading assets"
download_latest_assets Atmosphere-NX Atmosphere

log-info "Extracting *atmosphere*.zip"
quiet unzip "*atmosphere*.zip" -d "$OUTPUT_DIR" || die "Could not extract *atmosphere*.zip"

log-info "Moving fusee-primary.bin"
mkdir -p "$OUTPUT_DIR/bootloader/payloads"
cp fusee-primary.bin "$OUTPUT_DIR/bootloader/payloads/"

log-info "Create /atmosphere/kips"
mkdir "$OUTPUT_DIR/atmosphere/kips/"
