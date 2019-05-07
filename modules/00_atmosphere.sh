#!/usr/bin/env bash

log-info "Atmosphere"

log-info "Downloading assets"
download_latest_assets Atmosphere-NX Atmosphere

log-info "Extracting *atmosphere*.zip"
unzip "*atmosphere*.zip" -d "$OUTPUT_DIR" || die "Could not extract *atmosphere*.zip"

log-info "Moving fusee-primary.bin"
mkdir -p "$OUTPUT_DIR/bootloader/payloads"
cp fusee-primary.bin "$OUTPUT_DIR/bootloader/payloads/"

log-info "Copying titles"
cp -r "$CONFIG_DIR/atmosphere/titles"/* "$OUTPUT_DIR/atmosphere/titles/"

log-info "Copying system_settings.ini"
cp "$CONFIG_DIR/atmosphere/system_settings.ini" "$OUTPUT_DIR/atmosphere/"
