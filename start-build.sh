#! /usr/bin/env bash

export USE_LLVM=true
MAKEPKG_ARGS=-fdc
if [[ ${CI} == true ]];then
    sudo chown -R builder:builder .
    root=/home/builder/build_files
    conf=/home/builder/makepkg-aarch64.conf
else
    root=$(realpath $(dirname $0))
    if [[ $(uname -m) == "aarch64" ]]
    then
        conf=${root}/makepkg-distcc.conf
        MAKEPKG_ARGS=-fcsr
    else
        conf=${root}/makepkg-aarch64.conf
    fi
fi
echo "\$root is ${root}."
source ${root}/common.sh
PKGEXT=$(grep PKGEXT= ${conf} | sed "s/PKGEXT=//;s/'//g")
mkdir -p ${root}/out
[[ ! -f ${root}/status ]] && rm -f ${root}/out/*${PKGEXT}
touch ${root}/status
for package in $(find ${root} -maxdepth 1 -mindepth 1 -type d -exec test -e '{}/PKGBUILD' \; -print)
do
    relative_package=${package#${root}/}
    is_in_line ${root}/status ${relative_package} && continue
    [[ -f ${root}/skip ]] && is_in_line ${root}/skip ${relative_package} && continue
    echo "Processing ${relative_package} folder..."
    cd ${package}
    makepkg ${MAKEPKG_ARGS} --config=${conf}
    mv *${PKGEXT} ${root}/out
    echo ${relative_package} >> ${root}/status
done
[[ -f ${root}/status ]] && rm -f ${root}/status
