#!/usr/bin/env bash


declare -r PODMAN=${PODMAN:-podman} # docker
declare -r LOG=${LOG:-2} # 0=error 1=warn 2=info 3=debug
declare -r ALARM_URL="${ALARM_URL:-http://os.archlinuxarm.org}"

#shellcheck disable=SC2155
declare -r _root="$(realpath "$(dirname "$0")")"
declare -r _depends=("buildah" "$PODMAN")
declare -r _pkgdest="$_root/out"
declare -r _logdest="$_root/log"
declare -r _base_image_tag="alarm:base-devel"
# retun codes:
declare -r _NORMAL_EXIT=0
declare -r _ERR_NO_BINARY=1
declare -r _ERR_QEMU_FLAG_INVALID=2


# Print a log
# log $level $content
function log() {
    _reset="\e[0m"
    _error_left="\e[40;31m"
    _error_right="$_reset"
    _warn_left="\e[40;33m"
    _warn_right="$_reset"
    _info_left="\e[46;37m"
    _info_right="$_reset"
    _debug_left="\e[47;33m"
    _debug_right="$_reset"
    ready=false
    case $1 in
        error) # 0
            if [[ $LOG -ge 0 ]]
            then
                echo -ne "$_error_left$(date +%Y-%m-%d\ %H:%M:%S) [EROR]$_error_right "
                ready=true
            fi
            ;;
        warn) # 1
            if [[ $LOG -ge 1 ]]
            then
                echo -ne "$_warn_left$(date +%Y-%m-%d\ %H:%M:%S) [WARN]$_warn_right "
                ready=true
            fi
            ;;
        info) # 2
            if [[ $LOG -ge 2 ]]
            then
                echo -ne "$_info_left$(date +%Y-%m-%d\ %H:%M:%S) [INFO]$_info_right "
                ready=true
            fi
            ;;
        debug) # 3
            if [[ $LOG -ge 3 ]]
            then
                echo -ne "$_debug_left$(date +%Y-%m-%d\ %H:%M:%S) [DEBG]$_debug_right "
                ready=true
            fi
            ;;
    esac
    if $ready
    then
        echo "$2"
    fi
}

# If a string in one line of a file
# is_in_line /path/to/file $string
function is_in_line() {
    if [[ -f "$1" ]]
    then
        while read -r line
        do
            [[ "$2" == "${line}" ]] && return 0
        done < "$1"
    fi
    return 1
}

# Check depends
# check_depends
function check_depends() {
    for bin in "${_depends[@]}"
    do
        log info "Checking $bin..."
        command -v "$bin" > /dev/null || return 1
    done
    return 0
}

# Check QEMU User Static setting if its flags is OCF
# See https://github.com/multiarch/qemu-user-static/issues/17
# check_qemu_flags
function check_qemu_flags() {
    result=0
    while read -r file
    do
        interpreter=$(grep interpreter "$file" | sed 's/interpreter //')
        flags=$(grep flags "$file" | sed 's/flags: //')
        # aarch64_be matches aarch64
        if [[ "$interpreter" =~ aarch64- ]] && ! [[ "$flags" =~ OCF ]]
        then
            result=1
            break
        fi
    done < <(find /proc/sys/fs/binfmt_misc -mindepth 1 -maxdepth 1 ! -name register ! -name status)
    return $result
}

# Log a message and exit program
# log_and_exit $content $code
function log_and_exit() {
    if [[ $2 -eq 0 ]]
    then
        log info "$1"
    else
        log error "$1"
    fi
    exit "$2"
}

# Exec a hook
# exec_hook $file $args...
function exec_hook() {
    log debug "Trying calling hook $1..."
    if [[ -x "./$1" ]]
    then
        "./$*" || log error "Hook $1 failed to execute!"
    fi
    return 0
}

# Create the basic runtime image if needed
# create_base_image
function create_base_image() {
    if [[ $($PODMAN image list -q $_base_image_tag | wc -l) -eq 0 ]]
    then
        log info "Creating basic runtime image $_base_image_tag..."
        bootstrap_container=$(buildah from curlimages/curl:latest)
        buildah run --user=root "$bootstrap_container" apk upgrade --no-cache
        buildah run --user=root "$bootstrap_container" apk add libarchive-tools
        buildah run --user=root "$bootstrap_container" mkdir /alarm
        if [[ -f ArchLinuxARM-aarch64-latest.tar.gz ]]
        then
            buildah copy "$bootstrap_container" ArchLinuxARM-aarch64-latest.tar.gz
        else
            buildah run --user=root "$bootstrap_container" curl -LO "$ALARM_URL/os/ArchLinuxARM-aarch64-latest.tar.gz"
        fi
        # TODO: Use bsdtar once `Path contains '..' is fixed.`
        buildah run --user=root "$bootstrap_container" tar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C /alarm
        container=$(buildah from --arch=arm64 scratch)
        buildah copy --from="$bootstrap_container" "$container" /alarm/ /
        buildah run "$container" bash -c "echo Server = $ALARM_URL/\\\$arch/\\\$repo > /etc/pacman.d/mirrorlist"
        buildah run "$container" pacman-key --init
        buildah run "$container" pacman-key --populate archlinuxarm
        buildah run "$container" pacman-key --populate archlinux
        buildah run "$container" pacman -Syu --noconfirm
        buildah run "$container" pacman -S base-devel --needed --noconfirm
        buildah run "$container" useradd -r builder
        buildah run "$container" bash -c "echo builder ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/00-builder"
        buildah run "$container" mkdir /build /srcdest /pkgdest /logdest
        buildah run "$container" chown builder:builder /build /srcdest /pkgdest /logdest
        if [[ -d "$_root/containers" ]]
        then
            log info "Adding extra file(s) to container..."
            buildah copy "$container" "$_root/containers" /
        fi
        log info "Creating image..."
        buildah commit "$container" "$_base_image_tag"
        buildah rm "$bootstrap_container"
        buildah rm "$container"
    else
        log info "There is no need to create basic runtime image."
    fi
}

set -e

# main
check_depends || log_and_exit "No required executable found." $_ERR_NO_BINARY
if [[ "$(uname -m)" != "aarch64" ]]
then
    check_qemu_flags || log_and_exit "QEMU User Static binary interpreter flag is not OCF!" $_ERR_QEMU_FLAG_INVALID
fi
create_base_image

log info "Preparing files..."
[[ ! -f "$_root/status" ]] && rm -f out/*
touch "$_root/status"

exec_hook before-build
mkdir -p "$_pkgdest" "$_logdest"
while read -r package
do
    if is_in_line "$_root/status" "$package"
    then
        log debug "Skipping $package because it is built..."
        continue
    fi
    if [[ -f "$_root/skip" ]] && is_in_line "$_root/skip" "$package"
    then
        log debug "Skipping $package because it is in $_root/skip..."
        continue
    fi
    if [[ ! -f "$_root/$package/PKGBUILD" ]]
    then
        log error "No $package's PKGBUILD found, skipping..."
        continue
    fi
    log info "Building $package..."
    exec_hook before-package-build "$package"
    # shellcheck disable=SC2086
    $PODMAN run --arch arm64 --name "alarmbuilder-$package" \
        --workdir /startdir \
        --user builder \
        -v "$_root/$package:/startdir" \
        -e "BUILDDIR=/build" \
        -e "PKGDEST=/pkgdest" \
        -e "LOGDEST=/logdest" \
        -e "SRCDEST=/srcdest" \
        $CONTAINER_ARGS \
        $_base_image_tag \
        start-build
    $PODMAN wait "alarmbuilder-$package"
    $PODMAN cp "alarmbuilder-$package:/pkgdest" "$_pkgdest"
    $PODMAN cp "alarmbuilder-$package:/logdest" "$_logdest"
    $PODMAN container rm "alarmbuilder-$package"
    echo "$package" >> "$_root/status"
done < "$_root/build-orders"
exec_hook after-build
rm "$_root/status"
mv "$_pkgdest/pkgdest/"*.pkg.tar.* "$_pkgdest"
mv "$_logdest/logdest/"*.log "$_logdest"
rm -r "$_pkgdest/pkgdest" "$_logdest/logdest"
