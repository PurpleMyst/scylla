echo_level 0 "Atmosphere"

echo_level 1 "Downloading"
download_latest_assets Atmosphere-NX Atmosphere

echo_level 1 "Extracting"
unzip -q "*atmosphere*.zip" -d $OUTPUT_DIR
