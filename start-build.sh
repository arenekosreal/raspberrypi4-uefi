#! /usr/bin/env bash

root=$PWD
mkdir -p out
if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
    conf=/home/builder/makepkg-aarch64.conf
else
    conf=${root}/makepkg-aarch64.conf
fi
for package in $(find . -type f -name PKGBUILD | sed "s_./__;s_/PKGBUILD__")
do
    cd ${root}/${package}
    makepkg -fd --config=${conf}
    cp *.pkg.tar.zst ${root}/out
done
