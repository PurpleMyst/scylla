#!/usr/bin/env sh

export OUTPUT_DIR=$(realpath "sd-$(date '+%Y-%m-%d')")
export ASSET_DIR=$(realpath "$(mktemp -d -t scylla_assets.XXX)")

echo_level() {
    for _ in $(seq 1 $1); do
        echo -n " "
    done

    echo ${@:2}
}
export -f echo_level

download_latest_assets() {
    if [ $# -ne 2 ]; then
        echo "USAGE: $0 USER REPO"
        exit 1
    fi

    local release_url="https://api.github.com/repos/$1/$2/releases/latest"
    local release_info=$(wget -qO- "$release_url")
    local release_name=$(jq -r ".name" <<< $release_info)

    local assets_url=$(jq -r ".assets_url" <<< $release_info)
    local assets_info=$(wget -qO- "$assets_url")

    for asset in $(jq -c ".[]" <<< $assets_info); do
        local url=$(jq -r ".browser_download_url" <<< $asset)
        local filename=$(jq -r ".name" <<< $asset)

        echo_level 2 "Downloading asset $filename"
        wget -qO "$filename" "$url"
    done
}
export -f download_latest_assets

check_devkitpro_packages() {
    if [ -z "$DEVKITPRO" ]; then
        echo_level 1 "Could not find DevKitPro, please install it to run this module"
        exit 1
    fi

    if [ -x $(command -v dkp-pacman) ]; then
        local pacman=dkp-pacman
    elif [ -x $(command -v pacman) ]; then
        local pacman=pacman
    else
        echo_level 1 "Could not find DevKitPro pacman"
        exit 1
    fi

    for package in $@; do
        if ! ( $pacman -Qi $package > /dev/null 2>&1 || $pacman -Qg $package > /dev/null 2>&1 ); then
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
    echo_level 0 "Putting SD files into $OUTPUT_DIR"
    rm -rf $OUTPUT_DIR
    mkdir -p $OUTPUT_DIR

    modules=$(find modules -type f -executable -exec realpath {} \; | sort)
    cd $ASSET_DIR
    for module in $modules; do
        $module

        if [ $? -ne 0 ]; then
            exit 1
        fi
    done
}

main
