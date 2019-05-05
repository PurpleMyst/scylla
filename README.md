# scylla

`scylla` is a simple shell script that allows you to set up an SD card for
Switch Hacking.

## Requirements

`scylla` parses JSON to download GitHub releases and parses a GBATemp thread to
download IPS patches, so it requires shell tools for both of those tasks.

It also uses DevKitPro to compile some of the system modules.

- jq ( https://stedolan.github.io/jq/ )
- pup ( https://github.com/ericchiang/pup )
- DevKitPro ( https://devkitpro.org/ )

## Usage

Look in `modules/` and make the files you want to run executable, and the
files you don't want to run non-executable. You can use `chmod +x FILE` or
`chmod -x FILE` to do this.

Then, just run `./scylla.sh`, wait a bit, and magically an
`sd-YEAR-MONTH-DAY/` directory will have appeared.

## Special Thanks

Special thanks to `Toph` on the HBG Discord for helping me out with this and
giving me the idea!
