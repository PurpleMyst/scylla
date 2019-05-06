echo_level 0 "Bootlogo"

echo_level 1 "Decoding"

echo_level 1 "Gunzipping"
cp $CONFIG_DIR/bootloader/bootlogo.bmp.gz .
gunzip bootlogo.bmp.gz

echo_level 1 "Moving"
mv bootlogo.bmp $OUTPUT_DIR/bootloader/
