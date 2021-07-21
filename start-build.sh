#! /usr/bin/env bash
if [[ ! -f PKGBUILD ]];then
    git clone https://github.com/zhanghua000/raspberrypi-uefi-boot .
fi
 makepkg -fd --config=/home/builder/makepkg-aarch64.conf
