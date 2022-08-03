#! /usr/bin/env bash

# Build Ach Linux ARM packages for RaspberryPi 4B in UEFI mode
# You can choose directly build under Arch Linux x86_64 host or use aarch64 chroot build.
#
# Chroot build requirements:
#   sudo/doas, armutils 
#   Follow https://gitlab.com/mipimipi/armutils to finish setting up an aarch64 chroot 
#   environment and install build requirements in Dockerfile into chroot environment.
#
# Direct build requirements:
#   See Dockerfile
#
# Note: 
#      1. Direct build is also available on aarch64 environment if you have installed gcc10,
#         that means you can build this repo on your RaspberryPi which runs an Arch Linux ARM
#         if you have installed proper dependencies in Dockerfile.
#      2. Start chroot build by passing argument --chroot, like bash start-build.sh --chroot,
#         You can also set CHROOT environment variable to true to start chroot build.
#      3. Set environment variable SUDO to which you want, like sudo or doas, we use sudo
#         by default.
#      4. We use llvm to build those packages by default, you can set environment variable
#         USE_LLVM to false to use gcc cross-compile toolchain.
#      5. We use $HOME/chroot/aarch64 as default chroot path, yo can use your own path by 
#         setting CHROOT_ROOT environment variable.
#      6. If you build under aarch64 architecture, we use distcc to speed up. You may have
#         to configure distcc. You can set LOCAL environment variable to true to disable
#         this.

set -e

function is_in_line(){
    # is_in_line /path/to/file $string
    for line in $(cat $1)
    do
        [[ "$2" == "${line}" ]] && return 0
    done
    return 1
}

MAKEPKG_ARGS=-fdc
CHROOT_MAKEPKG_ARGS=-sc
CI=${CI:-false}
CHROOT=${CHROOT:-false}
LOCAL=${LOCAL:-false}
SUDO=${SUDO:-sudo}
CHROOT_ROOT=${CHROOT_ROOT:-${HOME}/chroot/aarch64}

if ${CI}
then
    sudo chown -R builder:builder .
    root=/home/builder/build_files
    conf=/home/builder/makepkg-aarch64.conf
else
    root=$(realpath $(dirname $0))
    if [[ $(uname -m) == "aarch64" ]]
    then
        if ${LOCAL}
        then
            conf=${root}/makepkg-aarch64.conf
        else
            conf=${root}/makepkg-distcc.conf
        fi
        MAKEPKG_ARGS=-fcsr
    else
        conf=${root}/makepkg-aarch64.conf
    fi
fi

export root
export USE_LLVM=${USE_LLVM:-true}

for config_file in $(find configs -type f)
do
    install -Dm644 ${config_file} ${root}/tmp/src/$(basename ${config_file})
done
[[ $1 == "--chroot" ]] && \
    CHROOT=true && shift && echo "Starting chroot build..."
echo "\$root is ${root}."
PKGEXT=$(grep PKGEXT= ${conf} | sed "s/PKGEXT=//;s/'//g")
mkdir -p ${root}/out
[[ ! -f ${root}/tmp/status ]] && rm -f ${root}/out/*${PKGEXT}
touch ${root}/tmp/status
for relative_package in $(cat ${root}/build-orders)
do
    is_in_line ${root}/tmp/status ${relative_package} && continue
    [[ -f ${root}/skip ]] && is_in_line ${root}/skip ${relative_package} && continue
    [[ ! -f ${root}/${relative_package}/PKGBUILD ]] && continue
    echo "Processing ${relative_package} folder..."
    cd ${root}/${relative_package}
    if $CHROOT
    then
        ${SUDO} makearmpkg -r ${CHROOT_ROOT} -- ${CHROOT_MAKEPKG_ARGS}
    else
        makepkg ${MAKEPKG_ARGS} --config=${conf}
    fi
    echo ${relative_package} >> ${root}/tmp/status
done
[[ -f ${root}/tmp/status ]] && rm -f ${root}/tmp/status
