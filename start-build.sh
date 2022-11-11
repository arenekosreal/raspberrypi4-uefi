#! /usr/bin/env bash

# Build Ach Linux ARM packages for RaspberryPi 4B in UEFI mode
#
# Requirements:
#   sudo/doas, armutils, devtools 
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

set -e

function is_in_line(){
    # is_in_line /path/to/file $string
    for line in $(cat $1)
    do
        [[ "$2" == "${line}" ]] && return 0
    done
    return 1
}

function check_depends(){
    command -v ${SUDO} > /dev/null || return 1
    if [[ $(uname -m) == "aarch64" ]] 
    then
        command -v mkarchroot > /dev/null || return 1
        command -v makechrootpkg > /dev/null || return 1
    else
        command -v mkarmchroot > /dev/null || return 1
        command -v makearmpkg > /dev/null || return 1
    fi
    return 0
}

function echo_and_exit(){
    # echo_and_exit $content $code
    echo $1
    exit $2
}

root=$(realpath $(dirname $0))

# For public
CHROOT_MAKEPKG_ARGS=${CHROOT_MAKEPKG_ARGS}
MAKECHROOTPKG_ARGS=${MAKECHROOTPKG_ARGS}
SUDO=${SUDO:-sudo}
CHROOT_ROOT=${CHROOT_ROOT:-${root}/tmp/chroot/aarch64}
ALARM_URL=${ALARM_URL:-http://os.archlinuxarm.org}

# For internal use
extra_packages=(git python acpica clang llvm lld)

# Environment
export PKGDEST=${root}/out
export SRCDEST=${root}/tmp/src
export LOGDEST=${root}/tmp/log

check_depends || echo_and_exit 'Dependencies check failed, please make sure you have installed them.' 1

for config_file in $(find ${root}/configs -type f)
do
    install -Dm644 ${config_file} ${root}/tmp/src/$(basename ${config_file})
done

mkdir -p ${root}/{out,tmp/{src,log}}
[[ ! -f ${root}/tmp/status ]] && rm -f out/*
touch ${root}/tmp/status
if [[ ! -d ${root}/tmp/chroot/aarch64/root ]]
then
    if [[ $(uname -m) == "aarch64" ]]
    then
        ${SUDO} mkarchroot \
            ${root}/tmp/chroot/aarch64/root base-devel ${extra_packages[@]}
    else
        ${SUDO} mkarmchroot \
            -u ${ALARM_URL}/os/ArchLinuxARM-aarch64-latest.tar.gz \
            ${root}/tmp/chroot/aarch64/root base-devel ${extra_packages[@]}
    fi
fi

for relative_package in $(cat ${root}/build-orders)
do
    is_in_line ${root}/tmp/status ${relative_package} && continue
    [[ -f ${root}/skip ]] && is_in_line ${root}/skip ${relative_package} && continue
    [[ ! -f ${root}/${relative_package}/PKGBUILD ]] && continue
    echo "Processing ${relative_package} folder..."
    cd ${root}/${relative_package}
    if [[ $(uname -m) == "aarch64" ]]
    then
        makechrootpkg -cu -r ${CHROOT_ROOT} -l uefi ${MAKECHROOTPKG_ARGS} \
            -- ${CHROOT_MAKEPKG_ARGS}
    else
        makearmpkg -cu -r ${CHROOT_ROOT} -l uefi ${MAKECHROOTPKG_ARGS} \
            -- ${CHROOT_MAKEPKG_ARGS}
    fi
    echo ${relative_package} >> ${root}/tmp/status
done
[[ -f ${root}/tmp/status ]] && rm -f ${root}/tmp/status
