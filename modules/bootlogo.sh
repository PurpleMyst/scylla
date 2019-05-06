#!/usr/bin/env bash

log-info "Bootlogo"

log-info "Uncompressing bootlogo.bmp.gz"
cp "$CONFIG_DIR/bootloader/bootlogo.bmp.gz" .
gunzip bootlogo.bmp.gz

log-info "Moving bootlogo.bmp"
mv bootlogo.bmp "$OUTPUT_DIR/bootloader/"
