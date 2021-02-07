# Maintainer: zhanghua <zhanghua.00@qq.com>

KBRANCH=5.10
GIT_HUB=https://github.com
GIT_RAW=https://raw.githubusercontent.com

# Uncomment these to use mirrorsite
GIT_HUB=https://hub.fastgit.org
GIT_RAW=https://raw.fastgit.org

pkgbase=raspberrypi4-uefi-boot-git
pkgname=("raspberrypi4-uefi-firmware-git" "raspberrypi4-uefi-kernel-git" "raspberrypi4-uefi-kernel-headers-git")
pkgver=5.10.13_uefi_d8a55b0
pkgrel=1
_pkgdesc="Raspberry Pi 4 UEFI boot files"
url="https://github.com/zhanghua000/raspberrypi-uefi-boot"
arch=("aarch64" "x86_64")
licence=("custom:LICENCE.EDK2" "custom:LICENCE.broadcom" "GPL")
depends=("grub" "dracut")
makedepends=("git" "acpica" "python" "rsync" "bc" "xmlto" "docbook-xsl" "kmod" "inetutils")
if [ ${CARCH} != "aarch64" ];then
    makedepends+=("aarch64-linux-gnu-gcc")
fi
options=(!strip)
sha256sums=('SKIP'
            '51e358cdad35c801ba29d0f94784c5202ca3468a5b3b7dae78e1de72d06b868a'
            'd17e4c9145edd05c2b081bb5edd7962203c4b77c41d2405d584782d7263f863e'
            '0c8a06c443b40f08cae7e0bc5e6244dbbfff658065695341b03e91dcf5308b63'
            '50ce20c9cfdb0e19ee34fe0a51fc0afe961f743697b068359ab2f862b494df80'
            'c7283ff51f863d93a275c66e3b4cb08021a5dd4d8c1e7acc47d872fbe52d3d6b'
            '24239fdc50df04a3042d2aa0b551d06fe126aecc4fc236e41e5faa07e1f6c8ad'
            'c2eb2ff734648cae829610867538f8faf43ae67f201a2ac12d9b68058d5b9ca3'
            '0e07ea2d056832e8c3f46836c9657ce0c515f14a2060b376e260f099c1f3288d'
            '8b98a8eddcda4e767695d29c71958e73efff8496399cfe07ab0ef66237f293bb'
            'ea69d22dedc607fee75eec57d8a4cc0f0eab93cd75393e61a64c49fbac912d02')
source=(
	"git+${GIT_HUB}/pftf/RPi4"
	99-update-initramfs.hook
	98-modify-grub-kernel-cmdline.hook
	switch-power-gov-to-ondemand.patch
	LICENCE.EDK2::${GIT_HUB}/tianocore/edk2/raw/master/License.txt
	LICENCE.broadcom::${GIT_HUB}/raspberrypi/firmware/raw/master/boot/LICENCE.broadcom
	${GIT_RAW}/raspberrypi/firmware/master/boot/bcm2711-rpi-4-b.dtb
	${GIT_RAW}/raspberrypi/firmware/master/boot/fixup4.dat
	${GIT_RAW}/raspberrypi/firmware/master/boot/start4.elf
	${GIT_RAW}/raspberrypi/firmware/master/boot/overlays/miniuart-bt.dtbo
	${GIT_RAW}/raspberrypi/firmware/master/boot/overlays/disable-bt.dtbo
)

pkgver(){
	if [  ${CARCH} != "aarch64"  ];then
		export ARCH=arm64
		export CrOSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/RPi4
	FIRMWAREVER=$(git rev-parse --short HEAD)
	cd ${srcdir}/linux
	#KERNELVER=$(git rev-parse --short HEAD)
	KERNELVER=$(make kernelversion | sed "s/-1//;s/-/_/;s/_v8+//")
	echo ${KERNELVER}_uefi_${FIRMWAREVER}
}

prepare(){
    	local file
	local dir
    	echo "Use ${GIT_HUB} as mirrorsite."
    	if [ ! -d linux ];then
        	git clone --depth=1 -b rpi-${KBRANCH}.y ${GIT_HUB}/raspberrypi/linux.git ${srcdir}/linux
		# add pkgrel to extraversion
		sed -ri "s|^(EXTRAVERSION =)(.*)|\1 \2-${pkgrel}|" ${srcdir}/linux/Makefile
    	else
        	if [ ${CARCH} != "aarch64" ];then
            		export ARCH=arm64
            		export CROSS_COMPILE=aarch64-linux-gnu-
        	fi
        	cd linux
        	git fetch origin
        	#make clean
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
	sh build_firmware.sh || sudo sh build_firmware.sh
	cd ${srcdir}/linux
	if [ ${CARCH} != "aarch64" ];then
        	export ARCH=arm64
        	export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	make bcm2711_defconfig
	patch .config ${srcdir}/switch-power-gov-to-ondemand.patch
	make prepare
	make -j$(cat /proc/cpuinfo |grep "processor"|wc -l)
}

package_raspberrypi4-uefi-firmware-git(){
	backup=("boot/config.txt")
	local file
	mkdir -p ${pkgdir}/boot/overlays
	cd ${srcdir}/RPi4
	pkgdesc="UEFI firmware for Raspberry Pi boot files for ${_pkgdesc}"
	cp ${srcdir}/RPi4/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd ${pkgdir}/boot/
	cat>${pkgdir}/boot/config.txt<<EOF
arm_64bit=1
enable_uart=1
enable_gic=1
armstub=RPI_EFI.fd
disable_commandline_tags=2
device_tree_address=0x1f0000
device_tree_end=0x200000
dtoverlay=miniuart-bt
EOF
	for file in bcm2711-rpi-4-b.dtb fixup4.dat start4.elf
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
	pkgdesc="The Linux Kernel and modules for ${_pkgdesc}"
	depends=("coreutils" "linux-firmware" "kmod" "dracut" "firmware-raspberrypi" "raspberrypi4-uefi-firmware-git")
	optdepends=("crda: to set the correct wireless channels of your country")
	provides=("kernel26" "linux")
	conflicts=("kernel26" "linux" "uboot-raspberrypi")
	backup=("boot/cmdline.txt")
	replaces=("linux-raspberrypi-latest")
    	if [ ${CARCH} != "aarch64" ];then
        	export ARCH=arm64
        	export CROSS_COMPILE=aarch64-linux-gnu-
	fi
    	local file
	mkdir -p ${pkgdir}/{boot,usr/include}
	cd ${srcdir}/linux
	kernver=$(make kernelrelease)
	basekernel=${kernver%%-*}
	basekernel=${basekernel%.*}
	make zinstall INSTALL_PATH=${pkgdir}/boot
	make modules_install INSTALL_MOD_PATH=${pkgdir}/usr
	ln -s "../extramodules-${basekernel}-rpi4-uefi" "${pkgdir}/usr/lib/modules/${kernver}/extramodules"
	echo ${kernver} | install -Dm644 /dev/stdin ${pkgdir}/usr/lib/modules/${kernver}/extramodules-${basekernel}-rpi4-uefi/version
	rm ${pkgdir}/usr/lib/modules/${kernver}/{source,build}
	mkdir ${pkgdir}/boot/overlays
	for file in $(ls arch/arm64/boot/dts/overlays/*.dtbo*);
	do
		if [[  ${file} == "arch/arm64/boot/dts/overlays/miniuart-bt.dtbo" ]] || [[ ${file} == "arch/arm64/boot/dts/overlays/disable-bt.dtbo"  ]];
		then
			continue
		fi
		cp ${file} ${pkgdir}/boot/overlays/
	done
	cp arch/arm64/boot/dts/overlays/README ${pkgdir}/boot/overlays/
	echo "root=LABEL=ROOT_MNJRO rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop usbhid.mousepoll=8 snd-bcm2835.enable_compat_alsa=0 audit=0" > ${pkgdir}/boot/cmdline.txt
	mkdir -p ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/99-update-initramfs.hook ${pkgdir}/usr/share/libalpm/hooks/
	sed -i "s/%KERNELVER%/`make kernelrelease`/g" ${pkgdir}/usr/share/libalpm/hooks/99-update-initramfs.hook
	cp ${srcdir}/98-modify-grub-kernel-cmdline.hook ${pkgdir}/usr/share/libalpm/hooks/
}
package_raspberrypi4-uefi-kernel-headers-git(){
	if [ ${CARCH} != "aarch64" ];then
        	export ARCH=arm64
        	export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/linux
	pkgdesc="Header files and scripts for building modules for linux kernel"
	provides=("linux-headers")
	conflicts=("linux-headers")
	replaces=("linux-raspberrypi-latest-headers")
	#make headers_install INSTALL_HDR_PATH=${pkgdir}/usr
	kernver=$(make kernelrelease)
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build -m644 Makefile .config Module.symvers
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/kernel -m644 kernel/Makefile
	mkdir ${pkgdir}/usr/lib/modules/${kernver}/build/.tmp_versions
	cp -t ${pkgdir}/usr/lib/modules/${kernver}/build -a include scripts
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/arch/arm64 -m644 arch/arm64/Makefile
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/arch/arm64/kernel -m644 arch/arm64/kernel/asm-offsets.s
	cp -t ${pkgdir}/usr/lib/modules/${kernver}/build/arch/arm64 -a arch/arm64/include
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/drivers/md -m644 drivers/md/*.h
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/net/mac80211 -m644 net/mac80211/*.h
	# http://bugs.archlinux.org/task/13146
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/drivers/media/i2c -m644 drivers/media/i2c/msp3400-driver.h
	# http://bugs.archlinux.org/task/20402
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/drivers/media/usb/dvb-usb -m644 drivers/media/usb/dvb-usb/*.h
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/drivers/media/dvb-frontends -m644 drivers/media/dvb-frontends/*.h
	install -Dt ${pkgdir}/usr/lib/modules/${kernver}/build/drivers/media/tuners -m644 drivers/media/tuners/*.h

	# add xfs and shmem for aufs building
	mkdir -p ${pkgdir}/usr/lib/modules/${kernver}/build/{fs/xfs,mm}
	# copy in Kconfig files
	find . -name Kconfig\* -exec install -Dm644 {} "${pkgdir}/usr/lib/modules/${kernver}/build/{}" \;
	# remove unneeded architectures
	local arch
	for arch in ${pkgdir}/usr/lib/modules/${kernver}/build/arch/*/;do
		[[ ${arch} == */arm64/ ]] && continue
		rm -r ${arch}
	done
	# remove files already in linux-docs package
	rm -r ${pkgdir}/usr/lib/modules/${kernver}/build/Documentation
	# remove now broken symlinks
	find -L "${pkgdir}/usr/lib/modules/${kernver}/build" -type l -printf 'Removing %P\n' -delete
	# Fix permissions
	chmod -R u=rwX,go=rX "${pkgdir}/usr/lib/modules/${kernver}/build"
	# strip scripts directory
	local _binary _strip
	while read -rd '' _binary; do
    	case "$(file -bi "${_binary}")" in
      		*application/x-sharedlib*)  _strip="${STRIP_SHARED}"   ;; # Libraries (.so)
      		*application/x-archive*)    _strip="${STRIP_STATIC}"   ;; # Libraries (.a)
      		*application/x-executable*) _strip="${STRIP_BINARIES}" ;; # Binaries
      		*) continue ;;
    	esac
    	/usr/bin/strip ${_strip} "${_binary}"
  	done < <(find "${pkgdir}/usr/lib/modules/${kernver}/build/scripts" -type f -perm -u+w -print0 2>/dev/null)
	
}

