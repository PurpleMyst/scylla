#!/usr/bin/env bash

STDERR_TTY=$(test -t 2)$?
export STDERR_TTY

# Output a message with provenance information and color to stderr.
# No color codes are outputted if stderr is not a tty.
#
# Arguments:
#   $1 -> ANSI color code (e.g. $'\033[31m')
#   $2 -> Message
#
# Failure:
#   1. Not enough arguments
log() {
    test $# -eq 2 || die "USAGE: log COLOR MESSAGE"

    if [[ $STDERR_TTY -eq 0 ]]; then
        color="$1"
        endcolor=$'\033[0m'
    else
        color=""
        endcolor=""
    fi

    printf $'[%s] %s%s%s\n' "$(basename "$0" .sh)" "$color" "$2" "$endcolor" >&2
}
export -f log

# Same as `log`, but $1 is $'\033[34m', the ANSI code for blue.
log-info() {
    log $'\033[34m' "$@"
}
export -f log-info

# Same as `log`, but $1 is $'\033[34m', the ANSI code for red.
log-error() {
    log $'\033[31m' "$@"
}
export -f log-error

# Output a message with `log-error` and exit with code 1.
#
# Arguments:
#   $@ -> passed to `log-error`
die() {
    log-error "$@"
    exit 1
}
export -f die

# Run a command, adding a `-q` argument if `$VERBOSE` is empty or unset.
#
# Arguments:
#   $1 -> program name
#   ${@:2} -> program arguments
#
# Special cases:
#   $1 = "git" -> `-q` is inserted after the first argument, not before.
#   $1 = "make" -> Instead of adding `-q`, stdout and stderr are redirected to /dev/null
quiet() {
    if [[ -n $VERBOSE ]]; then
        $1 "${@:2}"
    else
        case $1 in
        git)
            $1 "$2" -q "${@:3}"
            ;;

        make)
            $1 "${@:2}" &> /dev/null
            ;;

        *)
            $1 -q "${@:2}"
            ;;
        esac
    fi
}
export -f quiet

# for gnu parallel
_download_asset() {
    local url
    url=$(jq -r ".browser_download_url" <<< "$1")

    local filename
    filename=$(jq -r ".name" <<< "$1")

    log-info "Downloading asset $filename"
    quiet wget -O "$filename" "$url" || die "Could not download asset"
}
export -f _download_asset

_github_api_call() {
    local result exit_code
    result=$(quiet wget \
             --content-on-error=on \
             ${GITHUB_OAUTH_TOKEN:+--header="Authorization: token $GITHUB_OAUTH_TOKEN"} \
             -O- "$1")
    exit_code=$?

    case $exit_code in
        0)
            echo "$result"
            ;;

        8)
            error="$(jq -r ".message" <<< "$result")"
            log-error "GitHub API returned error for $1"
            log-error "Message: $error"
            return 1
            ;;

        *)
            log-error "Could not download $1 (wget exit code: $exit_code)"
            return 1
            ;;
    esac
}
export -f _github_api_call

_maybe_parallel() {
    if [[ -z $NO_PARALLEL && -x $(command -v parallel) ]]; then
        parallel --halt now,fail=1 "$@"
    else
        while IFS= read -r arg; do
            "$@" "$arg"
        done
    fi
}
export -f _maybe_parallel

# Download the latest GitHub release assets of a repo.
#
# Arguments:
#   $1 -> GitHub username of the repo's owner
#   $2 -> The repo's name
#
# Failure:
#   1. Not enough arguments provided
#   2. Tried to access unexistent or private repo
#   3. Rate limit reached
#   4. Could not download asset
download_latest_assets() {
    if [[ $# -ne 2 ]]; then
        die "USAGE: download_latest_assets USER REPO"
    fi

    log-info "Getting release info"
    local release_info
    release_info=$(_github_api_call "https://api.github.com/repos/$1/$2/releases") || exit 1

    log-info "Getting asset info"
    local assets_info
    assets_info=$(_github_api_call "$(jq -r ".[0] | .assets_url" <<< "$release_info")") || exit 1

    jq -c ".[]" <<< "$assets_info" | _maybe_parallel _download_asset
}
export -f download_latest_assets

# Verify the installation of DevKitPro and of its packages.
#
# Arguments:
#   $@ -> Names of packages to verify the installation of
#
# Failure:
#   1. $DEVKITPRO unset or empty
#   2. Neither `dkp-pacman` nor `pacman` present
#   3. Any of $@ not installed
check_devkitpro_packages() {
    if [[ -z $DEVKITPRO ]]; then
        die "Could not find DevKitPro, please install it to run this module"
    fi

    local pacman
    if [[ -x $(command -v dkp-pacman) ]]; then
        pacman=dkp-pacman
    elif [[ -x $(command -v pacman) ]]; then
        pacman=pacman
    else
        die "Could not find DevKitPro pacman"
    fi

    for package in "$@"; do
        if ! ( $pacman -Qi "$package" &> /dev/null || $pacman -Qg "$package" &> /dev/null ); then
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

# Install an NSP into `/atmosphere/titles/`
#
# Arguments:
#   $1 -> base name of the NSP (e.g. "sys-ftpd" )
#   ${@:2} -> flags for the title
#
# Failure:
#   1. Not enough arguments
#   2. Missing "title_id" in "$1.json"
#   3. `cp` error
install_nsp() {
    if [[ $# -lt 1 ]]; then
        die "USAGE: install_nsp BASENAME FLAGS"
    fi

    log-info "Determining title"
    title=$(jq -r ".title_id" < "$1.json") || die "Could not determine title"

    title=$(sed 's/^0x//' <<< "$title") || die "Could not remove 0x from title"

    log-info "Moving $1.nsp"
    mkdir "$OUTPUT_DIR/atmosphere/titles/$title"
    cp "$1.nsp" "$OUTPUT_DIR/atmosphere/titles/$title/exefs.nsp" || die "Could not move $1.nsp"

    mkdir "$OUTPUT_DIR/atmosphere/titles/$title/flags"
    for flag in "${@:2}"; do
        log-info "Adding flag $flag"
        touch "$OUTPUT_DIR/atmosphere/titles/$title/flags/$flag.flag" || die "Could not add flag $flag"
    done
}
export -f install_nsp

run_modules() {
    local modules
    mapfile -t modules < <(find modules -type f -perm -111 -exec realpath {} \; | sort)

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

    pushd "$ASSET_DIR" &> /dev/null || die "\$ASSET_DIR pulled out from under our feet!"
    for module in "${sequential_modules[@]}"; do
        $module || exit 1
    done

    if ! ( printf $'%s\n' "${parallel_modules[@]}" | _maybe_parallel ); then
        if [[ -z $NO_PARALLEL ]]; then
            log-error "Parallel module failed"
            log-error "Look for anything red (except this), and see if it tells you what to do"
            log-error "If you can't find anything, set the environment variable \$NO_PARALLEL and run again"
        fi

        exit 1
    fi
    popd &> /dev/null || die "Old WD pulled out from under our feet"  # shut up shellcheck
}

# Create a fresh directory and return its real path
fresh-dir() {
    if [[ -d $1 ]]; then
        rm -rf "$1"
    fi

    # We must create `$1` before giving it to `realpath` due to
    # BSD `realpath` only accepting pre-existing folders.
    mkdir -p "$1"
    realpath "$1"
}

main() {
    if [[ ! -x $(command -v realpath) ]]; then
        log-error "Could not find realpath binary"
        if [[ $(uname) = Darwin ]]; then
            log-error "You can install it from https://github.com/harto/realpath-osx"
        fi
        exit 1
    fi

    if [[ -f .github_oauth_token && -z "$GITHUB_OAUTH_TOKEN" ]]; then
        log-info "Loading OAuth token from .github_oauth_token"
        GITHUB_OAUTH_TOKEN="$(cat .github_oauth_token)"
        export GITHUB_OAUTH_TOKEN
    fi

    OUTPUT_DIR=$(fresh-dir "sd-$(date '+%Y-%m-%d')")
    ASSET_DIR=$(realpath "$(mktemp -d -t scylla_assets.XXX)")
    CACHE_DIR="${XDG_CACHE_DIR:-$HOME/.cache}/scylla"
    mkdir -p "$CACHE_DIR"
    export ASSET_DIR CACHE_DIR OUTPUT_DIR

    log-info "Putting SD files into $OUTPUT_DIR"

    run_modules

    log-info "Copying template/*"
    cp -r template/* "$OUTPUT_DIR/"
}

main
