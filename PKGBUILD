# Maintainer: zhanghua <zhanghua.00@qq.com>

KBRANCH=5.11
GIT_HUB=https://github.com
GIT_RAW=https://raw.githubusercontent.com

# Uncomment these to use mirrorsite
GIT_HUB=https://hub.fastgit.org
GIT_RAW=https://raw.fastgit.org

pkgbase=raspberrypi4-uefi-boot-git
pkgname=(raspberrypi4-uefi-firmware-git raspberrypi4-uefi-kernel-git raspberrypi4-uefi-kernel-header-git)
pkgver=d8a55b0_a63790d02 #Firmware Version_Kernel Version (All are git commit strings)
pkgrel=1
pkgdesc="Raspberry Pi 4 UEFI boot files"
url="https://github.com/zhanghua000/raspberrypi-uefi-boot"
arch=("aarch64" "x86_64")
licence=("custom:LICENCE.EDK2" "custom:LICENCE.broadcom" "GPL")
depends=("grub" "dracut")
makedepends=("git" "acpica" "python" "rsync")
if [ ${CARCH} != "aarch64" ];then
    makedepends+=("aarch64-linux-gnu-gcc")
    options=(!strip)
fi
conflicts=("linux-rpi4" "linux-rpi4-mainline" "linux-rpi4-rc" "uboot-raspberrypi" "linux" "linux-mainline" "linux-rc")
sha256sums=('SKIP'
            'e6dc26a2bec6ff37e5b4ad9acb96a98c26d8d0d0959379531ca81ab67061d181'
            '87be683b20f5e97155ce0c1f1f555d2700bd65f2c09ce39c821fbadf93516d2c'
            '0c8a06c443b40f08cae7e0bc5e6244dbbfff658065695341b03e91dcf5308b63'
            'fd309f6d078365ce5273d03a6256b019e1693a99c4909c1ffd1b9ff06fd51b39'
            '50ce20c9cfdb0e19ee34fe0a51fc0afe961f743697b068359ab2f862b494df80'
            'c7283ff51f863d93a275c66e3b4cb08021a5dd4d8c1e7acc47d872fbe52d3d6b'
            '5f69f0d4f0c3ab23d9d390efbdf1e23159b20bbda14a759f0c9e3fe90cf78e6a'
            '5c8a0197532eea767ff8d36edf4ec5a8c82cfeb910103a30b1b95bf5461652ab'
            'a915ddfa20778d434416d8751c6da3e2396026e650aadfe162ccc88469374cb5'
            '8b98a8eddcda4e767695d29c71958e73efff8496399cfe07ab0ef66237f293bb'
            'ea69d22dedc607fee75eec57d8a4cc0f0eab93cd75393e61a64c49fbac912d02')
source=(
	"git+${GIT_HUB}/pftf/RPi4"
	99-update-initramfs.hook
	98-modify-grub-kernel-cmdline.hook
	switch-power-gov-to-ondemand.patch
	config.txt
	LICENCE.EDK2::${GIT_HUB}/tianocore/edk2/raw/master/License.txt
	LICENCE.broadcom::${GIT_HUB}/raspberrypi/firmware/raw/master/boot/LICENCE.broadcom
	${GIT_RAW}/raspberrypi/firmware/master/boot/bcm2711-rpi-4-b.dtb
	${GIT_RAW}/raspberrypi/firmware/master/boot/fixup4.dat
	${GIT_RAW}/raspberrypi/firmware/master/boot/start4.elf
	${GIT_RAW}/raspberrypi/firmware/master/boot/overlays/miniuart-bt.dtbo
	${GIT_RAW}/raspberrypi/firmware/master/boot/overlays/disable-bt.dtbo
)

pkgver(){
	cd ${srcdir}/RPi4
	FIRMWAREVER=$(git rev-parse --short HEAD)
	cd ${srcdir}/linux
	KERNELVER=$(git rev-parse --short HEAD)
	echo ${FIRMWAREVER}_${KERNELVER}
}

prepare(){
    local file
	local dir
    echo "Use ${GIT_HUB} as mirrorsite."
    if [ ! -d linux ];then
        git clone --depth=1 -b rpi-${KBRANCH}.y ${GIT_HUB}/raspberrypi/linux.git linux
    else
        if [ ${CARCH} != "aarch64" ];then
            export ARCH=arm64
            export CROSS_COMPILE=aarch64-linux-gnu-
        fi
        cd linux
        git fetch origin
        make clean
    fi
    # Will move this to source list when makepkg supports --depth=1 option or we have to clone a huge repository.
	cd ${srcdir}/RPi4
	if [ ${CARCH} == "aarch64" ];then
		sed "s/export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-/# export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-/" -i build_firmware.sh 
		# Remove cross-compile flag to start native compiling if running on aarch64 device.
	fi
	sed "11s/^/# /" -i build_firmware.sh
	# Remove debug build as its files are useless, we only need release build files.
	# Or you can comment line 12 of build script to use debug build files.
	for dir in . edk2 edk2-platforms edk2/CryptoPkg/Library/OpensslLib/openssl edk2/BaseTools/Source/C/BrotliCompress/brotli edk2/MdeModulePkg/Library/BrotliCustomDecompressLib/brotli
	do
		echo "Modifying ${dir}/.gitmodules"
		cd ${srcdir}/RPi4/${dir}/
		sed -i "s_https://github.com_${GIT_HUB}_g; s_https://boringssl.googlesource.com_${GIT_HUB}/google_g" .gitmodules
		git submodule update --init
	done
	cd ${srcdir}/RPi4
    # Apply modification to let submodules on github also use mirrorsite.
    
	git submodule update --init --recursive || echo "Skipping getting some submodules due to Internet connection problem."
	# Maybe this line should be removed.

}

build(){
	cd ${srcdir}/RPi4
	sh build_firmware.sh
	cd ${srcdir}/linux
	if [ ${CARCH} != "aarch64" ];then
        export ARCH=arm64
        export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	make bcm2711_defconfig
	patch .config ${srcdir}/switch-power-gov-to-ondemand.patch
	make -j$(cat /proc/cpuinfo |grep "processor"|wc -l)
}

package_raspberrypi4-uefi-firmware-git(){
	local file
	mkdir -p ${pkgdir}/boot/overlays
	cd ${srcdir}/RPi4
	pkgdesc="UEFI firmware for Raspberry Pi boot files"
	cp ${srcdir}/RPi4/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd ${pkgdir}/boot/
	for file in config.txt bcm2711-rpi-4-b.dtb fixup4.dat start4.elf
	do
		cp ${srcdir}/${file} ${pkgdir}/boot/
	done
	for file in miniuart-bt.dtbo disable-bt.dtbo
	do
		cp ${srcdir}/${file} ${pkgdir}/boot/overlays/
	done
    install -Dm644 ${srcdir}/LICENCE.EDK2 "$pkgdir"/usr/share/licenses/$pkgname/LICENCE.EDK2
    install -Dm644 ${srcdir}/LICENCE.broadcom "$pkgdir"/usr/share/licenses/$pkgname/LICENCE.broadcom
    echo "There are some files conflicting with some same-name files provided by raspberrypi-boot-loader, "
	echo "the latter may not suit for this firmware package. "
    echo "You have to overwrite them with --overwrite option."
	
}

package_raspberrypi4-uefi-kernel-git(){
    if [ ${CARCH} != "aarch64" ];then
        export ARCH=arm64
        export CROSS_COMPILE=aarch64-linux-gnu-
	fi
    local file
	cd ${pkgdir}
	mkdir -p {boot,usr/include}
	cd ${srcdir}/linux
	pkgdesc="Kernel for Raspberry Pi UEFI boot files"
	make zinstall INSTALL_PATH=${pkgdir}/boot
	make modules_install INSTALL_MOD_PATH=${pkgdir}
	mkdir -p ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/99-update-initramfs.hook ${pkgdir}/usr/share/libalpm/hooks/
	sed -i "s/%KERNELVER%/`make kernelrelease`/g" ${pkgdir}/usr/share/libalpm/hooks/99-update-initramfs.hook
	cp ${srcdir}/98-modify-grub-kernel-cmdline.hook ${pkgdir}/usr/share/libalpm/hooks/
}
package_raspberrypi4-uefi-kernel-header-git(){
	if [ ${CARCH} != "aarch64" ];then
        export ARCH=arm64
        export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/linux
	pkgdesc="Kernel Header for Raspberry Pi UEFI boot files"
	make headers_install INSTALL_HDR_PATH=${pkgdir}
}
