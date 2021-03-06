# scylla

`scylla` is a simple shell script that allows you to set up an SD card for
Switch Hacking.

## Requirements

- jq to parse API responses ( https://stedolan.github.io/jq/ )
- pup to parse GBATemp threads ( https://github.com/ericchiang/pup )
- DevKitPro to compile sys modules ( https://devkitpro.org/ )
- unzip and p7zip to uncompress release assets
- Optionally, GNU parallel to run tasks in parallel

## Usage

Look in `modules/` and make the files you want to run executable, and the
files you don't want to run non-executable. You can use `chmod +x FILE` or
`chmod -x FILE` to do this.

Anything you put in `template/` will be copied to the sd card's root folder
after all modules have been ran.

Then, just run `./scylla.sh`, wait a bit, and magically an
`sd-YEAR-MONTH-DAY/` directory will have appeared.

## Troubleshooting

### Rate Limiting Errors

If you're getting rate limiting errors, which admittedly is pretty rare unless
you're developing this thing, there exists the option to increase your rate
limit from 60 requests/hour to 5000.

Set the enviroment variable `GITHUB_OAUTH_TOKEN` to a GitHub API OAuth2 token or write your token to a file in the current working directory called `.github_oauth_token`.
This sends your token as an header when making requests so that GitHub knows
who the requests are coming from. For more info on this method and on how
to generate a token
[here](https://developer.github.com/v3/#oauth2-token-sent-in-a-header).

### Can't download patches on MacOS

If you're on a MacOS High Sierra (or higher than Sierra), `pup` segfaults if installed via
the method listed in the project's `README`. A simple `brew uninstall pup`
then `brew install pup` installs a good version.

## Module Creators

- Thank you to rajkosto for ChoiDujourNX
- Thank you to WerWolv for EdiZon
- Thank you to XorTroll for Goldleaf
- Thank you to jakibaki for hid_mitm, sys-netcheat and sys-ftpd
- Thank you to blawar for incognito
- Thank you to spacemeowx2 for ldn_mitm
- Thank you to joel16 for NX-Shell
- Thank you to the retronx team for sys-clk

## Special Thanks

Special thanks to [sudot0ph](https://github.com/sudot0ph) for helping me out with this,
creating the bootlogo, and giving me the idea!
