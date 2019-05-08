#!/usr/bin/env bash
# Thanks to ITotalJustice for telling how to `sys-ftpd` as an NSP.
# https://github.com/PurpleMyst/scylla/issues/1

log-info "sys-ftpd"

check_devkitpro_packages switch-dev switch-mpg123

log-info "Cloning jakibaki/sys-ftpd"
quiet git clone https://github.com/jakibaki/sys-ftpd || die "Could not clone jakibaki/sys-ftpd"
cd sys-ftpd || die "sys-ftpd/ pulled out from under our feet"

log-info "Compiling sys-ftpd.nsp"
if [ -n "$VERBOSE" ]; then
    MAKE_STDOUT="/dev/stdout"
else
    MAKE_STDOUT="/dev/null"
fi
make &> "$MAKE_STDOUT" || die "Could not compile sys-ftpd.nsp"

log-info "Determining title"
title=$(jq -r ".title_id" < sys-ftpd.json) || die "Could not determine title"

log-info "Moving sys-ftpd.nsp"
mkdir "$OUTPUT_DIR/atmosphere/titles/$title"
cp sys-ftpd.nsp "$OUTPUT_DIR/atmosphere/titles/$title/exefs.nsp" || die "Could not move sys-ftpd.nsp"

log-info "Moving sd_card/*"
cp -r sd_card/* "$OUTPUT_DIR/"
