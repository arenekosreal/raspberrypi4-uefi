#! /usr/bin/env bash

if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
fi
root=$PWD
mkdir -p out
for package in raspberrypi4-uefi-firmware-git raspberrypi4-uefi-kernel-generic-git raspberrypi4-uefi-kernel-raspberrypi-git
do
    cd ${root}/${package}
    makepkg -fd --config=/home/builder/makepkg-aarch64.conf
    cp *.pkg.tar.zst ${root}/out
done
cd ${root}/out


