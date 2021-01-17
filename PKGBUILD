# Maintainer: zhanghua <zhanghua.00@qq.com>

KBRANCH=5.11
GIT_HUB=https://github.com
GIT_RAW=https://raw.githubusercontent.com

# Uncomment these to use mirrorsite
GIT_HUB=https://hub.fastgit.org
GIT_RAW=https://raw.fastgit.org

pkgbase=raspberrypi4-uefi-boot-git
pkgname=(raspberrypi4-uefi-firmware-git raspberrypi4-uefi-kernel-git)
pkgver=d8a55b0_a63790d02 #Firmware Version_Kernel Version (All are git commit strings)
pkgrel=1
pkgdesc="UEFI kernel and Firmware for Raspberry Pi 4"
url="https://github.com/zhanghua000/raspberrypi-uefi-boot"
arch=("aarch64" "x86_64")
licence=("custom:LICENCE.EDK2" "custom:LICENCE.broadcom" "GPL")
depends=("grub" "dracut")
makedepends=("git" "acpica" "python")
if [ ${CARCH} != "aarch64" ];then
    makedepends+=("aarch64-linux-gnu-gcc")
fi
conflicts=("linux-rpi4" "linux-rpi4-mainline" "linux-rpi4-rc")
sha256sums=('SKIP'
            '35813b05987c6875fc736be701c806d59ee09c96d2c8af19b069507cd97f854b'
            '0c8a06c443b40f08cae7e0bc5e6244dbbfff658065695341b03e91dcf5308b63'
            'fd309f6d078365ce5273d03a6256b019e1693a99c4909c1ffd1b9ff06fd51b39'
            '157549e4cf52ea118b50419894e8815ed779a365032c26cd8b898502cf87b71c'
            '50ce20c9cfdb0e19ee34fe0a51fc0afe961f743697b068359ab2f862b494df80'
            'c7283ff51f863d93a275c66e3b4cb08021a5dd4d8c1e7acc47d872fbe52d3d6b'
            '5f69f0d4f0c3ab23d9d390efbdf1e23159b20bbda14a759f0c9e3fe90cf78e6a'
            '6361c7a55eb9c0721eafee1f34e335414b4ca3184fca2d6e2cdb78c95242ebf4'
            '7f620cf146d1ff1e035137a26f7df09a9260d663f24eb81096d63c67332b8ebb'
            '8b98a8eddcda4e767695d29c71958e73efff8496399cfe07ab0ef66237f293bb'
            'ea69d22dedc607fee75eec57d8a4cc0f0eab93cd75393e61a64c49fbac912d02')
source=(
	"git+${GIT_HUB}/pftf/RPi4"
	99-update-initramfs.hook
	switch-power-gov-to-ondemand.patch
	config.txt
	42_add_manjaro_arm_for_rpi_entry
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
    if [ ! -d linux ];then
        git clone --depth=1 -b rpi-${KBRANCH}.y ${GIT_HUB}/raspberrypi/linux.git linux
    else
        cd linux
        git fetch origin
    fi
    # Will move this to source list when makepkg supports --depth option 
	cd ${srcdir}/RPi4
	if [ ${CARCH} == "aarch64" ];then
		sed "s/export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-//" -i build_firmware.sh 
		# remove cross-compile flag to start native compiling
	fi
	git submodule update --init --recursive || echo "Skipping getting some submodules due to Internet connection problem"
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
	make
}
package_raspberrypi4-uefi-firmware-git(){
	local file
	mkdir -p ${pkgdir}/boot/overlays
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
	cp .config ${pkgdir}/boot/config-$(make kernelrelease)
	cp System.map ${pkgdir}/boot/System.map-$(make kernelrelease)
	make zinstall INSTALL_PATH=${pkgdir}
	make modules_install INSTALL_MOD_PATH=${pkgdir}
	make headers_install INSTALL_HDR_PATH=${pkgdir}
	mkdir -p ${pkgdir}/grub.d
	cp ${srcdir}/42_add_manjaro_arm_for_rpi_entry ${pkgdir}/grub.d
	sed -i "s/%KERNELVER%/`make kernelrelease`/" ${pkgdir}/grub.d/42_add_manjaro_arm_for_rpi_entry
	mkdir -p ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/99-update-initramfs.hook ${pkgdir}/usr/share/libalpm/hooks/
	sed -i "s/%KERNELVER%/`make kernelrelease`/" ${pkgdir}/usr/share/libalpm/hooks/99-update-initramfs.hook
}
