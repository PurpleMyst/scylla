#!/usr/bin/env sh

export OUTPUT_DIR=$(realpath "sd-$(date '+%Y-%m-%d')")
export ASSET_DIR=$(realpath "$(mktemp -d -t dumbfuck_assets.XXX)")

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

main() {
    echo_level 0 "Putting SD files into $OUTPUT_DIR"
    rm -rf $OUTPUT_DIR
    mkdir -p $OUTPUT_DIR

    modules=$(find modules -type f -executable -exec realpath {} \; | sort)
    cd $ASSET_DIR
    echo $modules | xargs -n1 sh
}

main
