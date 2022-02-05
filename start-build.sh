#! /usr/bin/env bash

set -e
if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
    root=/home/builder/build_files
    conf=/home/builder/makepkg-aarch64.conf
else
    root=$PWD
    conf=${root}/makepkg-aarch64.conf
fi
echo "\$root is ${root}."
mkdir -p ${root}/out
rm -f ${root}/out/*.pkg.tar.zst
for package in $(find ${root} -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    echo "Processing ${package} folder..."
    cd ${package}
    makepkg -fd --config=${conf}
    mv *.pkg.tar.zst ${root}/out
    for folder in $(find ${package} -maxdepth 1 -mindepth 1 -type d -print)
    do
        rm -rf ${folder}
    done
done
