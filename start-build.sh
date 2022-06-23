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
PKGEXT=$(grep PKGEXT= ${conf} | sed "s/PKGEXT=//;s/'//g")
mkdir -p ${root}/out
[[ ! -f ${root}/status ]] && rm -f ${root}/out/*${PKGEXT}
touch ${root}/status
for package in $(find ${root} -maxdepth 1 -mindepth 1 -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    relative_package=${package#${root}/}
    [[ $(grep -c ${relative_package} ${root}/status) != 0 ]] && continue
    echo "Processing ${relative_package} folder..."
    cd ${package}
    makepkg ${MAKEPKG_ARGS} --config=${conf}
    mv *${PKGEXT} ${root}/out
    echo ${relative_package} >> ${root}/status
done
[[ -f ${root}/status ]] && rm -f ${root}/status
