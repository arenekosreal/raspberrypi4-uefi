#! /usr/bin/env bash

# Build Ach Linux ARM packages for RaspberryPi 4B in UEFI mode
#
# Requirements:
#   sudo/opendoas/..., bash
# Extra requirements on non-aarch64 platform:
#   sed, grep, armutils
# Extra requirements on aarch64 platform:
#   devtools
# Extra requirements when build packages on tmpfs:
#   mount, umount
#
# Note: 
#   1. Set environment variable SUDO to which you want, like sudo or doas, we use sudo
#      by default.
#   2. Set CHROOT_MAKEPKG_ARGS to what you want to pass to makepkg.
#   3. Set CHROOT_ROOT to where you want to save chroot environment, we use tmp/chroot/aarch64 
#      by default.
#   4. Set ALARM_URL to the mirrorsite you want, this may be useful for someone. We use 
#      official site http://os.archlinuxarm.org by default.
#      For ones live in China, you can use https://mirrors.bfsu.edu.cn/archlinuxarm instead 
#      default value.
#   5. Set MAKECHROOTPKG_ARGS to what you want to pass to makechrootpkg/makearmpkg
#   6. Set TMPFS to true to build packages in a tmpfs to save space. You can adjust mount
#      options by setting TMPFS_ARGS. This is only working when CI environment variable is
#      not set to true.
#   7. If you meet
#      `sudo: effective uid is not 0, is /usr/bin/sudo on a file system with the 'nosuid' option set
#       or an NFS file system without root privileges?`
#      on non-aarch64 environment, you may check this after you have followed sudo's output:
#      https://bbs.archlinux.org/viewtopic.php?id=242708
#      We have added a automatical fixup for this but once it fails, you need to do this manually.

set -e

root=$(realpath "$(dirname "$0")")

# For public
CHROOT_MAKEPKG_ARGS=""
MAKECHROOTPKG_ARGS=""
TMPFS_ARGS="defaults,size=12G,nodev"
CI="${CI:-false}"
TMPFS="${TMPFS:-false}"
SUDO="${SUDO:-sudo}"
CHROOT_ROOT="${CHROOT_ROOT:-${root}/tmp/chroot/aarch64}"
ALARM_URL="${ALARM_URL:-http://os.archlinuxarm.org}"

# Environment
export PKGDEST=${root}/out
export SRCDEST=${root}/tmp/src
export LOGDEST=${root}/tmp/log

function is_in_line(){
    # is_in_line /path/to/file $string
    while read -r line
    do
        [[ "$2" == "${line}" ]] && return 0
    done < "$1"
    return 1
}

function check_depends(){
    echo "Checking ${SUDO}..."
    command -v "${SUDO}" > /dev/null || return 1
    echo 'Checking tee...'
    command -v tee > /dev/null || return 1
    if [[ $(uname -m) == "aarch64" ]] 
    then
        echo 'Checking mkarchroot...'
        command -v mkarchroot > /dev/null || return 1
        echo 'Checking makechrootpkg...'
        command -v makechrootpkg > /dev/null || return 1
    else
        echo 'Checking mkarmchroot...'
        command -v mkarmchroot > /dev/null || return 1
        echo 'Checking makearmpkg...'
        command -v makearmpkg > /dev/null || return 1
        echo 'Checking grep...'
        command -v grep > /dev/null || return 1
        echo 'Checking sed...'
        command -v sed > /dev/null || return 1
    fi
    if ! ${CI} && ${TMPFS}
    then
        echo 'Checking mount...'
        command -v mount > /dev/null || return 1
        echo 'Checking umount...'
        command -v umount > /dev/null || return 1
    fi
    return 0
}

function echo_and_exit(){
    # echo_and_exit $content $code
    echo "$1"
    exit "$2"
}

function get_binfmt_interpreter() {
    # get_binfmt_interpreter $item
    grep "interpreter " "/proc/sys/fs/binfmt_misc/$1" | sed "s/interpreter //"
}

function get_binfmt_flags() {
    # get_binfmt_flags $item
    grep "flags: " "/proc/sys/fs/binfmt_misc/$1" | sed "s/flags: //"
}

function disable_binfmt_item() {
    # disable_binfmt_item $file
    echo -1 | ${SUDO} tee "/proc/sys/fs/binfmt_misc/$1" > /dev/null
}

function register_new_aarch64_binfmt_item() {
    # register_new_aarch64_binfmt_item $item
    #shellcheck disable=SC2028
    echo ":$1:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:OCF" | \
        ${SUDO} tee /proc/sys/fs/binfmt_misc/register > /dev/null
}

function get_aarch64_binfmt_item() {
    for file in /proc/sys/fs/binfmt_misc/*
    do
        item=${file//\/proc\/sys\/fs\/binfmt_misc\//}
        if [[ ${item} == "register" ]] || [[ ${item} == "status" ]]
        then
            continue
        elif [[ $(get_binfmt_interpreter "${item}") =~ qemu-aarch64-static$ ]]
        then
            echo "${item}"
            return 0
        fi
    done
}

echo 'Printing variables:'
echo "    CHROOT_MAKEPKG_ARGS=${CHROOT_MAKEPKG_ARGS}"
echo "    MAKECHROOTPKG_ARGS=${MAKECHROOTPKG_ARGS}"
echo "    TMPFS_ARGS=${TMPFS_ARGS}"
echo "    CI=${CI}"
echo "    TMPFS=${TMPFS}"
echo "    SUDO=${SUDO}"
echo "    CHROOT_ROOT=${CHROOT_ROOT}"
echo "    ALARM_URL=${ALARM_URL}"

check_depends || echo_and_exit 'Dependencies check failed, please make sure you have installed them.' 1

if [[ $(uname -m) != "aarch64" ]]
then
    aarch64_binfmt_item=$(get_aarch64_binfmt_item)
    if [[ -n ${aarch64_binfmt_item} ]] && [[ $(get_binfmt_flags "${aarch64_binfmt_item}") != "OCF" ]]
    then
        echo 'Trying to apply correct flags to aarch64 binfmt...'
        disable_binfmt_item "${aarch64_binfmt_item}"
        register_new_aarch64_binfmt_item "${aarch64_binfmt_item}"
    else
        echo 'There is no need to apply correct flags to aarch64 binfmt.'
    fi
fi

if ! ${CI} && ${TMPFS}
then
    if ! mount | grep -q "${root}/tmp type tmpfs"
    then
        ${SUDO} rm -rf "${root}/tmp"
        mkdir "${root}/tmp"
        echo "Mounting tmpfs on ${root}/tmp"
        ${SUDO} mount -t tmpfs -o "${TMPFS_ARGS}" tmpfs "${root}/tmp"
    fi
fi

find "${root}/configs" -type f | while read -r config_file
do
    install -Dm644 "${config_file}" "${root}/tmp/src/$(basename "${config_file}")"
done

mkdir -p "${root}"/{out,tmp/{src,log}}
[[ ! -f "${root}/tmp/status" ]] && rm -f out/*
touch "${root}/tmp/status"
if [[ ! -d ${CHROOT_ROOT}/root ]]
then
    if [[ $(uname -m) == "aarch64" ]]
    then
        ${SUDO} mkarchroot \
            "${CHROOT_ROOT}/root" base-devel
    else
        ${SUDO} mkarmchroot \
            -u "${ALARM_URL}/os/ArchLinuxARM-aarch64-latest.tar.gz" \
            "${CHROOT_ROOT}/root" base-devel
    fi
else
    if [[ $(uname -m) == "aarch64" ]]
    then
        ${SUDO} arch-nspawn \
            "${CHROOT_ROOT}/root" pacman -Syu --noconfirm
    else
        ${SUDO} arm-nspawn \
            "${CHROOT_ROOT}/root" pacman -Syu --noconfirm
    fi
fi

while read -r relative_package
do
    is_in_line "${root}/tmp/status" "${relative_package}" && continue
    [[ -f "${root}/skip" ]] && is_in_line "${root}/skip" "${relative_package}" && continue
    [[ ! -f "${root}/${relative_package}/PKGBUILD" ]] && continue
    echo "Processing ${relative_package} folder..."
    cd "${root}/${relative_package}"
    if [[ $(uname -m) == "aarch64" ]]
    then
        makechrootpkg -cu -r "${CHROOT_ROOT}" -l uefi "${MAKECHROOTPKG_ARGS}" \
            -- "${CHROOT_MAKEPKG_ARGS}"
    else
        makearmpkg -cu -r "${CHROOT_ROOT}" -l uefi "${MAKECHROOTPKG_ARGS}" \
            -- "${CHROOT_MAKEPKG_ARGS}"
    fi
    echo "${relative_package}" >> "${root}/tmp/status"
done < "${root}/build-orders"
[[ -f "${root}/tmp/status" ]] && rm -f "${root}/tmp/status"
if ! ${CI} && ${TMPFS}
then
    ${SUDO} umount "${root}/tmp"
fi
