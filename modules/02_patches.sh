#!/usr/bin/env bash

THREAD_URL="https://gbatemp.net/threads/i-heard-that-you-guys-need-some-sweet-patches-for-atmosphere.521164/"

log-info "IPS Patches"

if [ ! -x "$(command -v pup)" ]; then
    die "pup is not installed"
fi

log-info "Downloading gbatemp thread"
gbatemp_thread=$(quiet wget -O- "$THREAD_URL") || die "Could not download gbatemp thread"

log-info "Scraping attachment URL"
href=$(pup ".attachmentInfo > .filename > a attr{href}" <<< "$gbatemp_thread") || die "pup failed"
patches_url="https://gbatemp.net/$href"

log-info "Downloading patches.zip"
quiet wget -O patches.zip "$patches_url" || die "Could not download patches.zip"

log-info "Extracting patches.zip"
quiet unzip patches.zip -d patches || die "Could not extract patches.zip"

log-info "Moving patches to \$OUTPUT_DIR/atmosphere/"
cp -r patches/*/atmosphere/* "$OUTPUT_DIR/atmosphere/"
