#!/usr/bin/env bash

log-info "ChoiDujourNX"

log-info "Downloading https://switchtools.sshnuke.net/"
switchtools=$(quiet wget 'https://switchtools.sshnuke.net/' -O-) || die "Could not download https://switchtools.sshnuke.net/"

log-info "Scraping download link"
link=$(pup 'img[alt="ChoiDujourNX screenshot"] + p + ul > li:first-child > a > attr{href}' <<< "$switchtools") || die "Could not find download link"

log-info "Downloading ChoiDujourNX.zip"
quiet wget "$link" -O ChoiDujourNX.zip || die "Could not download ChoiDujourNX.zip"

log-info "Extracting ChoiDujourNX.zip"
quiet unzip ChoiDujourNX.zip -d ChoiDujourNX

log-info "Moving ChoiDujourNX.nro"
cp ChoiDujourNX/ChoiDujourNX.nro "$OUTPUT_DIR/switch/"
