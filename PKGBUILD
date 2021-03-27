# Maintainer: zhanghua <zhanghua.00@qq.com>

KBRANCH=5.12
# Only need if you are using raspberrypi kernel
USE_GENERIC_KERNEL=False
# Weather using generic kernel or raspberrypi kernel

GIT_HUB=https://github.com/
GIT_RAW=https://raw.githubusercontent.com/

# Uncomment these to use mirrorsite
# Mirrorsite 1
#GIT_HUB=https://hub.fastgit.org/
#GIT_RAW=https://raw.fastgit.org/
# Mirrorsite 2
#GIT_HUB=https://github.com.cnpmjs.org/
#GIT_RAW=https://raw.sevencdn.com/

pkgbase=raspberrypi4-uefi-boot-git
pkgname=("raspberrypi4-uefi-firmware-git" "raspberrypi4-uefi-kernel-git" "raspberrypi4-uefi-kernel-headers-git")
pkgver=5.12.0_c93a86897_uefi_07ab11c
pkgrel=1
_pkgdesc="Raspberry Pi 4 UEFI boot files"
url="https://github.com/zhanghua000/raspberrypi-uefi-boot"
arch=("aarch64")
licence=("custom:LICENCE.EDK2" "custom:LICENCE.broadcom" "GPL")
depends=("grub" "dracut" "raspberrypi-bootloader")
makedepends=("git" "acpica" "python" "rsync" "bc" "xmlto" "docbook-xsl" "kmod" "inetutils")
optdepends=("dracut-hook: Auto generate new initcpio and delete old initcpio when using dracut")
if [ ${CARCH} != "aarch64" ];then
    makedepends+=("aarch64-linux-gnu-gcc")
fi
options=(!strip)
sha256sums=('SKIP'
            'a78a818da59420e7aab11d34aeb10d6d3fc334618b7d49e923f94da4067ba589'
            '29e3aa43312b3b33908bda0009d08ca8642c1fcb2cd5cf3e9e5bb06685bdbd45'
            'f2394636d71522c7761f051e189050b4798f403a6bcd93e77ee772b5d13c723e'
            '0a6eb2a5a986e1d77ecec35805e04d6c9b54984c56a776d56ce87719ff532bb1'
            '50ce20c9cfdb0e19ee34fe0a51fc0afe961f743697b068359ab2f862b494df80'
            'c7283ff51f863d93a275c66e3b4cb08021a5dd4d8c1e7acc47d872fbe52d3d6b'
            'a1a4c6ab38c8daa18e83a15deaa2de6d31e5b51a8adc4cfbb8a7b25df7310341'
            '8b98a8eddcda4e767695d29c71958e73efff8496399cfe07ab0ef66237f293bb'
            'ea69d22dedc607fee75eec57d8a4cc0f0eab93cd75393e61a64c49fbac912d02')
source=(
	"git+${GIT_HUB}pftf/RPi4"
	97-modify-grub-kernel-cmdline.hook
	99-update-grub.hook
	generic-kernel-config-patch-for-raspberrypi-4b.patch
	raspberrypi-kernel-config-patch-for-raspberrypi-4b.patch
	LICENCE.EDK2::${GIT_RAW}tianocore/edk2/master/License.txt
	LICENCE.broadcom::${GIT_RAW}raspberrypi/firmware/master/boot/LICENCE.broadcom
	${GIT_RAW}raspberrypi/firmware/master/boot/bcm2711-rpi-4-b.dtb
	${GIT_RAW}raspberrypi/firmware/master/boot/overlays/miniuart-bt.dtbo
	${GIT_RAW}raspberrypi/firmware/master/boot/overlays/disable-bt.dtbo
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
	KERNELVER=$(make kernelversion | sed "s/-.*//")_$(git log --format=%h -1)
	echo ${KERNELVER}_uefi_${FIRMWAREVER}
}

prepare(){
    	local file
	local dir
    	echo "Use ${GIT_HUB} as mirrorsite."
    	if [ ! -d ${srcdir}/linux ];then
		mkdir ${srcdir}/linux
		cd ${srcdir}/linux
		git init -q
		if [ ${USE_GENERIC_KERNEL} == True ];then
			git fetch --depth=1 ${GIT_HUB}torvalds/linux.git master:makepkg
		else
        		git fetch --depth=1 ${GIT_HUB}raspberrypi/linux.git rpi-${KBRANCH}.y:makepkg
		fi
		git checkout makepkg
		sed -ri "s|^(EXTRAVERSION =)(.*)|\1 \2-${pkgrel}|" ${srcdir}/linux/Makefile
		# add pkgrel to extraversion
    	else
        	cd ${srcdir}/linux
        	#git reset --hard HEAD
		if [ -f .config ];then
			mv .config .config.old
		fi
    	fi
	# Move this to source once it supports --depth=1 option
	cd ${srcdir}/linux
	if [ ${CARCH} != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	if [ ${USE_GENERIC_KERNEL} == True ];then
		make defconfig
		patch .config ${srcdir}/generic-kernel-config-patch-for-raspberrypi-4b.patch
		# Have merged bcm2711_defconfig in raspberrypi's repo as much as I can
	else
		make bcm2711_defconfig
		patch .config ${srcdir}/raspberrypi-kernel-config-patch-for-raspberrypi-4b.patch
		# Have enabled ACPI subsystem based on bcm2711_defconfig	
	fi
	yes "" | make oldconfig
	make prepare
	cd ${srcdir}/RPi4
	if [ ${GIT_HUB} != "https://github.com" ];then
		for dir in . edk2 edk2-platforms edk2/CryptoPkg/Library/OpensslLib/openssl edk2/BaseTools/Source/C/BrotliCompress/brotli edk2/MdeModulePkg/Library/BrotliCustomDecompressLib/brotli
		do
			echo "Modifying ${dir}/.gitmodules"
			cd ${srcdir}/RPi4/${dir}/
			sed -i "s_https://github.com_${GIT_HUB}_g; s_https://boringssl.googlesource.com_${GIT_HUB}/google_g" .gitmodules
			git submodule update --init
		done
    		# Apply modification to let submodules on github also use mirrorsite.
    	else
		git submodule update --init --recursive
	fi
	cd ${srcdir}/RPi4
	FIRMVER=git-$(git rev-parse --short HEAD)
	cat>build_firmware.sh<<EOF
make -C edk2/BaseTools
export WORKSPACE=\$PWD
export PACKAGES_PATH=\$WORKSPACE/edk2:\$WORKSPACE/edk2-platforms:\$WORKSPACE/edk2-non-osi
export GCC5_AARCH64_PREFIX=""
export BUILD_FLAGS="-D SECURE_BOOT_ENABLE=TRUE -D INCLUDE_TFTP_COMMAND=TRUE -D NETWORK_ISCSI_ENABLE=TRUE"
source edk2/edksetup.sh
# EDK2's 'build' command doesn't play nice with spaces in environmnent variables, so we can't move the PCDs there...
build -a AARCH64 -t GCC5 -p edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc -b RELEASE --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor=L"https://github.com/pftf/RPi4" --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString=L"UEFI Firmware ${FIRMVER}" \${BUILD_FLAGS}

EOF
	chmod +x build_firmware.sh	
	patch --binary -d edk2 -p1 -i ../0001-MdeModulePkg-UefiBootManagerLib-Signal-ReadyToBoot-o.patch
	# apply patch in repo as repo does this in CI service
}

build(){
	# Build UEFI Firware
	cd ${srcdir}/RPi4
	bash build_firmware.sh || sudo bash build_firmware.sh
	# It may be failed to build on chroot environment with non-root user, use sudo to build it instead if failed.
	# Build Kernel
	if [ ${CARCH} != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/linux
	make -j$(nproc)
}

package_raspberrypi4-uefi-firmware-git(){
	backup=("boot/config.txt")
	pkgdesc="UEFI firmware for Raspberry Pi boot files for ${_pkgdesc}"
	local file
	mkdir -p ${pkgdir}/boot/overlays
	cp ${srcdir}/RPi4/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd ${pkgdir}/boot/
	cat>${pkgdir}/boot/config.txt<<EOF
arm_64bit=1
enable_uart=1
uart_2ndstage=1
enable_gic=1
armstub=RPI_EFI.fd
disable_commandline_tags=2
device_tree_address=0x1f0000
device_tree_end=0x200000
dtoverlay=miniuart-bt
EOF
	if [ ${USE_GENERIC_KERNEL} == True ];then
		cp ${srcdir}/bcm2711-rpi-4-b.dtb ${pkgdir}/boot
	
		for file in miniuart-bt.dtbo disable-bt.dtbo
		do
			cp ${srcdir}/${file} ${pkgdir}/boot/overlays/
		done
	fi
	# Raspberry Pi Kernel have provided these files
    	install -Dm644 ${srcdir}/LICENCE.EDK2 "${pkgdir}"/usr/share/licenses/${pkgname}/LICENCE.EDK2
    	install -Dm644 ${srcdir}/LICENCE.broadcom "${pkgdir}"/usr/share/licenses/${pkgname}/LICENCE.broadcom
	
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
	mkdir -p ${pkgdir}/boot
	cd ${srcdir}/linux
	kernver=$(make kernelrelease)
	basekernel=${kernver%%-*}
	basekernel=${basekernel%.*}
	make zinstall INSTALL_PATH=${pkgdir}/boot
	make modules_install INSTALL_MOD_PATH=${pkgdir}/usr
	make dtbs_install INSTALL_DTBS_PATH=${pkgdir}/boot/dtbs
	if [ ${USE_GENERIC_KERNEL} == False ];then
		cp arch/arm64/boot/dts/broadcom/bcm271*-rpi-*.dtb ${pkgdir}/boot
		mkdir ${pkgdir}/boot/overlays
		cp arch/arm64/boot/dts/overlays/*.dtbo* ${pkgdir}/boot/overlays/
		cp arch/arm64/boot/dts/overlays/README ${pkgdir}/boot/overlays/
	fi
	cp .config ${pkgdir}/boot/config-${kernver}
	ln -s "../extramodules-${basekernel}-rpi4-uefi" "${pkgdir}/usr/lib/modules/${kernver}/extramodules"
	echo ${kernver} | install -Dm644 /dev/stdin ${pkgdir}/usr/lib/modules/extramodules-${basekernel}-rpi4-uefi/version
	rm ${pkgdir}/usr/lib/modules/${kernver}/{source,build}
	echo "root=LABEL=ROOT_MNJRO rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop usbhid.mousepoll=8 snd-bcm2835.enable_compat_alsa=0 audit=0" > ${pkgdir}/boot/cmdline.txt
	mkdir -p ${pkgdir}/usr/bin
	cat>${pkgdir}/usr/bin/modify_grub_cmdline<<EOF
#!/usr/bin/sh
if [ -f /boot/cmdline.txt.pacsave ];then
	CMDFILE=/boot/cmdline.txt.pacsave
else
	CMDFILE=/boot/cmdline.txt
fi
CMDLINE="\`sed 's/^root=.\+ rw //' \${CMDFILE}\`"
sed -i 's/^GRUB_CMDLINE_LINUX=""$/GRUB_CMDLINE_LINUX="\${CMDLINE}"/' /etc/default/grub
echo "Finished modifying grub cmdline"
EOF
	chmod +x ${pkgdir}/usr/bin/modify_grub_cmdline
	mkdir -p ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/97-modify-grub-kernel-cmdline.hook ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/99-update-grub.hook ${pkgdir}/usr/share/libalpm/hooks/
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

