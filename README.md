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

## Troubleshooting

### Rate Limiting Errors

If you're getting rate limiting errors, which admittedly is pretty rare unless
you're developing this thing, there exists the option to increase your rate
limit from 60 requests/hour to 5000.

The first way is to set the enviroment variable `GITHUB_USERNAME` to your GitHub
username. This uses basic HTTP authorization to send GitHub your username such
that it knows who the requests are coming from. You can read up on this method
[here](https://developer.github.com/v3/#basic-authentication).

The second way is to set the enviroment variable `GITHUB_OAUTH_TOKEN` to a
GitHub API OAuth2 token. This sends that token as an header when making
requests so that it knows who the requests are coming from. You can read up on
this method and on how to generate a token
[here](https://developer.github.com/v3/#oauth2-token-sent-in-a-header).

### Can't download patches on MacOS

If you're on a MacOS higher than High Sierra, `pup` segfaults if installed via
the method listed in the project's `README`. A simple `brew uninstall pup`
then `brew install pup` installs a good version.

## Special Thanks

Special thanks to `Toph` on the HBG Discord for helping me out with this and
giving me the idea!
