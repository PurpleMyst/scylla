echo_level 0 "hid_mitm"

echo_level 1 "Downloading"
download_latest_assets jakibaki hid-mitm

echo_level 1 "Extracting"
unzip hid-mitm.zip -d $OUTPUT_DIR/
