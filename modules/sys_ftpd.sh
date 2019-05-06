#!/usr/bin/env bash
echo_level 0 "sys-ftpd"

check_devkitpro_packages switch-dev switch-mpg123

echo_level 1 "Cloning"
git clone https://github.com/jakibaki/sys-ftpd
cd sys-ftpd || exit 1

if [ -x "$(command -v nproc)" ]; then
    make_jobs=$(nproc)
elif [ "$(uname)" == "Darwin" ]; then
    make_jobs=$(sysctl -n hw.physicalcpu)
else
    make_jobs=1
fi

echo_level 1 "Compiling"
# These need to be separate because otherwise `make` considers `sys-ftpd.kip`
# an intermediate file and delets it after it's done. Which is not what we
# want, obviously.
make -j$make_jobs all
make -j$make_jobs sys-ftpd.kip

echo_level 1 "Moving"
mv sys-ftpd.kip "$OUTPUT_DIR/bootloader/kip-modules/"

echo_level 1 "Extracting"
cp -r sd_card/* "$OUTPUT_DIR/"
