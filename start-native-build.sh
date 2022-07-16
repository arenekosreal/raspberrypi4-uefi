#!/usr/bin/env bash

# This script allow you build aarch64 package on x86_64 host with native compile
# Requirements:
# An Arch Distribution
# armutils-git in AUR
# base-devel
# follow https://gitlab.com/mipimipi/armutils#example to setup an aarch64 chroot environment

root=$(realpath $(dirname $0))
chroot=$HOME/chroot/aarch64
source ${root}/common.sh
PKGEXT=$(grep PKGEXT= ${chroot}/etc/makepkg.conf | sed "s/PKGEXT=//;s/'//g")
mkdir -p ${root}/out
[[ ! -f ${root}/status ]] && rm -f ${root}/out/*${PKGEXT}
touch ${root}/status
for package in $(find ${root} -maxdepth 1 -mindepth 1 -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    relative_package=${package#${root}/}
    is_in_line ${root}/status ${relative_package} && continue
    [[ -f ${root}/skip ]] && is_in_line ${root}/skip ${relative_package} && continue
    echo "Processing ${relative_package} folder..."
    cd ${package}
    sudo makearmpkg -r ${chroot} -- -sc
    mv *${PKGEXT} ${root}/out
    echo ${relative_package} >> ${root}/status
done
[[ -f ${root}/status ]] && rm -f ${root}/status
