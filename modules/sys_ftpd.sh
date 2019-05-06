echo_level 0 "sys-ftpd"

check_devkitpro_packages switch-dev switch-mpg123

echo_level 1 "Cloning"
git clone https://github.com/jakibaki/sys-ftpd
cd sys-ftpd

echo_level 1 "Compiling"
# These need to be separate because otherwise `make` considers `sys-ftpd.kip`
# an intermediate file and delets it after it's done. Which is not what we
# want, obviously.
make -j$(nproc) all
make -j$(nproc) sys-ftpd.kip

echo_level 1 "Moving"
mv sys-ftpd.kip $OUTPUT_DIR/bootloader/kip-modules/

echo_level 1 "Extracting"
cp -t $OUTPUT_DIR -r sd_card/*
