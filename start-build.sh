#! /usr/bin/env bash
if [[ !-f PKGBUILD ]];then
    git clone https://github.com/zhanghua000/raspberrypi-uefi-boot .
fi
CARCH=aarch64 makepkg -fdC 
