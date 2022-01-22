#! /usr/bin/env bash

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
for package in $(find ${root} -type f -name PKGBUILD | sed "s_${root}/__;s_/PKGBUILD__")
do
    echo "Processing ${package} folder..."
    cd ${root}/${package}
    makepkg -fd --config=${conf}
    cp *.pkg.tar.zst ${root}/out
done
