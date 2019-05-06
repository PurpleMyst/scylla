echo_level 0 "Atmosphere"

echo_level 1 "Downloading"
download_latest_assets Atmosphere-NX Atmosphere

echo_level 1 "Extracting"
unzip "*atmosphere*.zip" -d $OUTPUT_DIR

echo_level 1 "Moving"
mkdir -p $OUTPUT_DIR/bootloader/payloads
cp fusee-primary.bin $OUTPUT_DIR/bootloader/payloads
