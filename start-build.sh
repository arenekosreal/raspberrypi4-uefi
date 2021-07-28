#! /usr/bin/env bash
if [[ ! -f PKGBUILD ]];then
    git clone https://github.com/zhanghua000/raspberrypi-uefi-boot .
fi
if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
fi
 makepkg -fd --config=/home/builder/makepkg-aarch64.conf
