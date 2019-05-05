echo_level 0 "Hekate"

echo_level 1 "Downloading"
download_latest_assets Joonie86 hekate

echo_level 1 "Extracting"
7z -y x "*hekate*.7z" -o$OUTPUT_DIR > /dev/null

echo_level 1 "Adding config"
cat > $OUTPUT_DIR/bootloader/hekate_ipl.ini << EOF
[config]
autoboot=1
autoboot_list=0
bootwait=3
customlogo=1
verification=2
backlight=100
autohosoff=0
autonogc=1

[Atmosphere]
payload=bootloader/payloads/fusee-primary.bin
{ }
EOF
