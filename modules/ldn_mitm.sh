echo_level 0 "ldn_mitm"

echo_level 1 "Downloading"
download_latest_assets spacemeowx2 ldn_mitm

echo_level 1 "Extracting"
unzip ldn_mitm_*.zip -d $OUTPUT_DIR/
