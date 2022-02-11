#!/usr/bin/env bash

# This script allow you build aarch64 package on x86_64 host with native compile
# Requirements:
# An Arch Distribution
# armutils-git in AUR
# base-devel
# follow https://gitlab.com/mipimipi/armutils#example to setup an aarch64 chroot environment

set -e
root=$PWD
chroot=$HOME/chroot/aarch64
mkdir -p ${root}/out
rm -f ${root}/out/*.pkg.tar.zst
for package in $(find ${root} -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    echo "Processing ${package} folder..."
    cd ${package}
    sudo makearmpkg -r ${chroot} -- -sc
    mv *.pkg.tar.zst ${root}/out
done
