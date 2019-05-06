#!/usr/bin/env bash

log() {
    test $# -eq 2 || die "USAGE: log COLOR MESSAGE"
    printf $'[%s] %s%s\033[0m\n' "$(basename "$0" .sh)" "$1" "$2"
}
export -f log

log-info() {
    log $'\033[34m' "$@"
}
export -f log-info

log-error() {
    log $'\033[31m' "$@"
}
export -f log-error

die() {
    log-error "$@"
    exit 1
}
export -f die

download_latest_assets() {
    if [ $# -ne 2 ]; then
        die "USAGE: download_latest_assets USER REPO"
    fi

    local release_url
    release_url="https://api.github.com/repos/$1/$2/releases/latest"

    log-info "Getting release info"
    local release_info
    release_info=$(wget --content-on-error=on ${GITHUB_OAUTH_TOKEN:+--header="Authorization: token $GITHUB_OAUTH_TOKEN"} -O- "$release_url") || die "Could not download release info"

    if jq -r ".message" <<< "$release_info" | grep -q "rate limit"; then
        die "Github API rate limit reached!"
    fi

    log-info "Getting asset info"
    local assets_url
    assets_url=$(jq -r ".assets_url" <<< "$release_info")
    local assets_info
    assets_info=$(wget -O- "$assets_url") || die "Could not download asset info"

    jq -c ".[]" <<< "$assets_info" | while IFS= read -r asset; do
        local url
        url=$(jq -r ".browser_download_url" <<< "$asset")

        local filename
        filename=$(jq -r ".name" <<< "$asset")

        log-info "Downloading asset $filename"
        wget -O "$filename" "$url" || die "Could not download asset"
    done
}
export -f download_latest_assets

check_devkitpro_packages() {
    if [ -z "$DEVKITPRO" ]; then
        die "Could not find DevKitPro, please install it to run this module"
    fi

    if [ -x "$(command -v dkp-pacman)" ]; then
        local pacman=dkp-pacman
    elif [ -x "$(command -v pacman)" ]; then
        local pacman=pacman
    else
        die "Could not find DevKitPro pacman"
    fi

    for package in "$@"; do
        if ! ( $pacman -Qi "$package" > /dev/null 2>&1 || $pacman -Qg "$package" > /dev/null 2>&1 ); then
            log-error "Could not find required DevKitPro package $package"
            log-error "You can install it by running:"
            log-error "$ sudo $pacman -S $package"
            exit 1
        else
            log-info "Found required DevKitPro package $package"
        fi
    done
}
export -f check_devkitpro_packages

main() {
    if [ ! -x "$(command -v realpath)" ]; then
        log-error "Could not find realpath binary"
        if [ "$(uname)" = "Darwin" ]; then
            log-error "You can install it from https://github.com/harto/realpath-osx"
        fi
        exit 1
    fi

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

    log-info "Putting SD files into $OUTPUT_DIR"

    local modules
    mapfile -t modules < <(find modules -type f -perm -111 -exec realpath {} \; | sort)

    if [ -z "$NO_PARALLEL" ] && [ -x "$(command -v parallel)" ]; then
        local sequential_modules
        sequential_modules=()

        local parallel_modules
        parallel_modules=()

        for module in "${modules[@]}"; do
            if [[ $(basename "$module") =~ ^[[:digit:]] ]]; then
                sequential_modules+=("$module")
            else
                parallel_modules+=("$module")
            fi
        done
    else
        sequential_modules=("${modules[@]}")
    fi

    cd "$ASSET_DIR" || die "\$ASSET_DIR pulled out from under our feet!"
    for module in "${sequential_modules[@]}"; do
        $module || die "Sequential module failed"
    done

    if [ -z "$NO_PARALLEL" ] && [ -x "$(command -v parallel)" ]; then
        if ! ( printf $'%s\n' "${parallel_modules[@]}" | parallel --halt now,fail=1 bash ); then
            log-error "Parallel module failed"
            log-error "Look for anything red (except this), and see if it tells you what to do"
            log-error "If you can't find anything, set the environment variable \$NO_PARALLEL and run again"
            exit 1
        fi
    fi
}

main
