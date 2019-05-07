#!/usr/bin/env bash
log-info "sys-ftpd"

check_devkitpro_packages switch-dev switch-mpg123

log-info "Cloning jakibaki/sys-ftpd"
git clone "$QUIET_FLAG" https://github.com/jakibaki/sys-ftpd || die "Could not clone jakibaki/sys-ftpd"
cd sys-ftpd || die "sys-ftpd/ pulled out from under our feet"

log-info "Compiling sys-ftpd.kip"
if [ -n "$QUIET_FLAG" ]; then
    MAKE_STDOUT="/dev/null"
else
    MAKE_STDOUT="/dev/stdout"
fi
# These need to be separate because otherwise `make` considers `sys-ftpd.kip`
# an intermediate file and delets it after it's done. Which is not what we
# want, obviously.
( make all && make sys-ftpd.kip ) &> "$MAKE_STDOUT" || die "Could not compile sys-ftpd.kip"

log-info "Moving sys-ftpd.kip"
cp sys-ftpd.kip "$OUTPUT_DIR/bootloader/kip-modules/"

log-info "Moving sd_card/*"
cp -r sd_card/* "$OUTPUT_DIR/"
