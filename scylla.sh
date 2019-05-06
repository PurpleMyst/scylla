#!/usr/bin/env bash

set -e

if [ ! -x "$(command -v realpath)" ]; then
    echo "Could not find readpath binary"
    if [ "$(uname)" = "Darwin" ]; then
        echo "You can install it from https://github.com/harto/realpath-osx"
    fi
    exit 1
fi

echo_level() {
    for _ in $(seq 1 "$1"); do
        echo -n " "
    done

    echo "${@:2}"
}
export -f echo_level

download_latest_assets() {
    if [ $# -ne 2 ]; then
        echo "USAGE: $0 USER REPO"
        exit 1
    fi

    local assets_url, assets_info, release_url, release_info

    release_url="https://api.github.com/repos/$1/$2/releases/latest"
    echo_level 2 "Getting release info"
    release_info=$(wget --content-on-error=on -O- "$release_url")

    if jq -r ".message" <<< "$release_info" | grep -q "rate limit"; then
        echo_level 2 "Github API rate limit reached!"
        exit 1
    fi

    echo_level 2 "Getting asset info"
    assets_url=$(jq -r ".assets_url" <<< "$release_info")
    assets_info=$(wget -O- "$assets_url")

    for asset in $(jq -c ".[]" <<< "$assets_info"); do
        local url, filename
        url=$(jq -r ".browser_download_url" <<< "$asset")
        filename=$(jq -r ".name" <<< "$asset")

        echo_level 2 "Downloading asset $filename"
        wget -O "$filename" "$url"
    done
}
export -f download_latest_assets

check_devkitpro_packages() {
    if [ -z "$DEVKITPRO" ]; then
        echo_level 1 "Could not find DevKitPro, please install it to run this module"
        exit 1
    fi

    if [ -x "$(command -v dkp-pacman)" ]; then
        local pacman=dkp-pacman
    elif [ -x "$(command -v pacman)" ]; then
        local pacman=pacman
    else
        echo_level 1 "Could not find DevKitPro pacman"
        exit 1
    fi

    for package in "$@"; do
        if ! ( $pacman -Qi "$package" > /dev/null 2>&1 || $pacman -Qg "$package" > /dev/null 2>&1 ); then
            echo_level 1 "Could not find required DevKitPro package $package"
            echo_level 2 "You can install it by running:"
            echo_level 2 "$ sudo $pacman -S $package"
            exit 1
        else
            echo_level 1 "Found required DevKitPro package $package"
        fi
    done
}
export -f check_devkitpro_packages

main() {
    local BASE_OUTPUT_DIR
    BASE_OUTPUT_DIR="sd-$(date '+%Y-%m-%d')"

    rm -rf "$BASE_OUTPUT_DIR"
    mkdir -p "$BASE_OUTPUT_DIR"

    # We must create `$BASE_OUTPUT_DIR` before giving it to `realpath` due to
    # BSD-like platforms such as MacOS only wanting to `realpath` pre-existing
    # folders.
    OUTPUT_DIR=$(realpath "$BASE_OUTPUT_DIR")
    ASSET_DIR=$(realpath "$(mktemp -d -t scylla_assets.XXX)")
    CONFIG_DIR=$(realpath config/)
    export OUTPUT_DIR
    export ASSET_DIR
    export CONFIG_DIR

    echo_level 0 "Putting SD files into $OUTPUT_DIR"

    if [ "$(uname)" == "Darwin" ]; then
        local perm="+111"
    else
        local perm="/a+x"
    fi

    local modules
    modules=$(find modules -type f -perm $perm -exec realpath {} \; | sort)
    cd "$ASSET_DIR"
    for module in $modules; do
        $module || exit 1
    done
}

main
