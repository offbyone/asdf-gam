#!/usr/bin/env bash
set -eu
[ "${BASH_VERSINFO[0]}" -ge 3 ] && set -o pipefail

get_platform() {
    local silent=${1:-}
    local platform=""

    platform="$(uname | tr '[:upper:]' '[:lower:]')"

    case "$platform" in
        linux | darwin)
            [ -z "$silent" ] && msg "Platform '${platform}' supported!"
            ;;
        *)
            fail "Platform '${platform}' not supported!"
            ;;
    esac

    echo -n "$platform"
}

get_arch() {
    local arch=""
    local arch_check=${ASDF_GOLANG_OVERWRITE_ARCH:-"$(uname -m)"}
    local platform=$(get_platform silently)
    local platform_arch="${arch_check}:${platform}"
    case "${platform_arch}" in
        *:darwin) arch="universal2" ;;
        x86_64 | amd64) arch="x86_64" ;;
        armv7l) arch="armv7l" ;;
        aarch64 | arm64) arch="aarch64" ;;
        *)
            fail "Arch '${arch_check}' not supported!"
            ;;
    esac

    echo -n $arch
}

get_suffix() {
    local suffix=""
    local arch="$(get_arch)"
    local platform=$(get_platform silently)
    local platform_arch="${arch}:${platform}"
    case "${platform_arch}" in
        *:darwin) suffix="" ;;
        aarch64:*) suffix="-glibc2.28" ;;
        armv7l:*) suffix="-glibc2.28" ;;
        x86_64:*) suffix="-glibc2.31" ;;
        *)
            fail "Platform/Arch '${platform_arch}' not supported!"
            ;;
    esac

    echo -n $suffix
}

get_extension() {
    echo -n "tar.xz"
}

get_filename() {
    echo -n "gam-${ASDF_INSTALL_VERSION}-$(get_platform silently)-$(get_arch)$(get_suffix).$(get_extension)"
}

msg() {
    echo -e "\033[32m$1\033[39m" >&2
}

err() {
    echo -e "\033[31m$1\033[39m" >&2
}

fail() {
    err "$1"
    exit 1
}
