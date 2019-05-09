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

install_nsp sys-ftpd boot2

log-info "Moving sd_card/*"
cp -r sd_card/* "$OUTPUT_DIR/"
