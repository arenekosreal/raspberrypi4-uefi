#! /usr/bin/env bash

set -e
MAKEPKG_ARGS=-fdc
export USE_LLVM=true
if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
    root=/home/builder/build_files
    conf=/home/builder/makepkg-aarch64.conf
else
    root=$PWD
    if [[ $(uname -m) == "aarch64" ]]
    then
        conf=${root}/makepkg-distcc.conf
        MAKEPKG_ARGS=-fcsr
    else
        conf=${root}/makepkg-aarch64.conf
    fi
fi
echo "\$root is ${root}."
mkdir -p ${root}/out
rm -f ${root}/out/*.pkg.tar.zst
for package in $(find ${root} -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    echo "Processing ${package} folder..."
    cd ${package}
    makepkg ${MAKEPKG_ARGS} --config=${conf}
    mv *.pkg.tar.zst ${root}/out
done
