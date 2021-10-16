# Maintainer: zhanghua <zhanghua.00@qq.com>

KBRANCH=5.15
# Only need if you are using raspberrypi kernel
USE_GENERIC_KERNEL=False
# Weather using generic kernel or raspberrypi kernel

GIT_HUB=https://github.com/
GIT_RAW=https://raw.githubusercontent.com/

# Uncomment these to use mirrorsite
# Mirrorsite 1
#GIT_HUB=https://mirror.ghproxy.com/https://github.com/
#GIT_RAW=https://mirror.ghproxy.com/https://raw.githubusercontent.com/
# Mirrorsite 2
#GIT_HUB=https://github.com.cnpmjs.org/
#GIT_RAW=https://raw.sevencdn.com/

pkgbase=raspberrypi4-uefi-boot-git
pkgname=("raspberrypi4-uefi-firmware-git" "raspberrypi4-uefi-kernel-git" "raspberrypi4-uefi-kernel-headers-git" "raspberrypi4-uefi-kernel-api-headers-git")
pkgver=5.15.0.551fd5f04_uefi_v1.31
pkgrel=1
_pkgdesc="Raspberry Pi 4 UEFI boot files"
url="https://github.com/zhanghua000/raspberrypi-uefi-boot"
arch=("aarch64")
licence=("custom:LICENCE.EDK2" "custom:LICENCE.broadcom" "GPL")
depends=("grub" "dracut" "raspberrypi-bootloader")
makedepends=("git" "acpica" "python" "rsync" "bc" "xmlto" "docbook-xsl" "kmod" "inetutils" "openssl")
options=(!strip)
if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
    makedepends+=("aarch64-linux-gnu-gcc")
    options+=(!ccache)
fi
sha256sums=('SKIP'
            'a7569f99eb13cc05a9170fe29a44a6939ab00ae6d78188d18fe5c73faabb1bb4'
            '9eac878438552601c43ca31a4987226a170a55ec86f7a0bfe2c772674742a526'
            '2829fb74f3b5692843ce7fec018a41035ac6184b494aa87447eba15b646c89f0'
            'b0f4953d47cf1d106675099b2902c65a25d88c8b54aea73df09091569480b7bf'
            'fde96a8c64307f9f51e882dc0fbd3445aa9b5a3a6a6e2cf57f3f1e197ce1d98c'
            '50ce20c9cfdb0e19ee34fe0a51fc0afe961f743697b068359ab2f862b494df80'
            'c7283ff51f863d93a275c66e3b4cb08021a5dd4d8c1e7acc47d872fbe52d3d6b'
            'a1117f516a32cefcba3f2d1ace10a87972fd6bbe8fe0d0b996e09e65d802a503'
            'e8e95f0733a55e8bad7be0a1413ee23c51fcea64b3c8fa6a786935fddcc71961'
            '48e99b991f57fc52f76149599bff0a58c47154229b9f8d603ac40d3500248507'
            'f42c187f8b01b497f81fb0459164b27d16ca2af0b95c7331a82c1a27a731a885')
source=(
	"git+${GIT_HUB}pftf/RPi4"
	97-modify-grub-kernel-cmdline.hook
	98-dracut-update-initramfs.hook
	dracut-update-initramfs
	generic-kernel-config-patch-for-raspberrypi-4b.patch
	raspberrypi-kernel-config-patch-for-raspberrypi-4b.patch
	LICENCE.EDK2::${GIT_RAW}tianocore/edk2/master/License.txt
	LICENCE.broadcom::${GIT_RAW}raspberrypi/firmware/master/boot/LICENCE.broadcom
	ms_kek.cer::https://go.microsoft.com/fwlink/?LinkId=321185
	ms_db1.cer::https://go.microsoft.com/fwlink/?linkid=321192
	ms_db2.cer::https://go.microsoft.com/fwlink/?linkid=321194
	arm64_dbx.bin::https://uefi.org/sites/default/files/resources/dbxupdate_arm64.bin
)

if [ ${USE_GENERIC_KERNEL} == True ];then
    source+=(
    	${GIT_RAW}raspberrypi/firmware/master/boot/bcm2711-rpi-4-b.dtb
	${GIT_RAW}raspberrypi/firmware/master/boot/overlays/miniuart-bt.dtbo
	${GIT_RAW}raspberrypi/firmware/master/boot/overlays/disable-bt.dtbo
    )
    sha256sums+=(
    	'a1a8c8893378133fb37c76ab1ccf9c9c1890c1a0b4525bce3c42815716a67844'
    	'8b98a8eddcda4e767695d29c71958e73efff8496399cfe07ab0ef66237f293bb'
    	'ea69d22dedc607fee75eec57d8a4cc0f0eab93cd75393e61a64c49fbac912d02'
    )
fi

pkgver(){
	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/RPi4
	FIRMWAREVER=$(git describe --tags)
	cd ${srcdir}/linux
	KERNELVER=$(make kernelversion | sed "s/-.*//").$(git log --format=%h -1)
	echo ${KERNELVER}_uefi_${FIRMWAREVER} | sed "s/-/./g;s/g//g"
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
    	else
        	cd ${srcdir}/linux
        	git reset --hard HEAD
		if [ -f .config ];then
			mv .config .config.old
		fi
    	fi
	# Move this to source once it supports --depth=1 option
	cd ${srcdir}/linux
	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	sed -ri "s|^(EXTRAVERSION =)(.*)|\1 \2-${pkgrel}|" Makefile
	# Add pkgrel to extraversion
	if [ ${USE_GENERIC_KERNEL} == True ];then
		make defconfig
		sed -i "/^#/d;/^$/d" .config
		# Remove lines start with #
		patch -i "${srcdir}/generic-kernel-config-patch-for-raspberrypi-4b.patch"
		# Have merged bcm2711_defconfig in raspberrypi's repo as much as I can
	else
		make bcm2711_defconfig
		sed -i "/^#/d;/^$/d" .config
		patch  -i "${srcdir}/raspberrypi-kernel-config-patch-for-raspberrypi-4b.patch"
		# Have enabled ACPI subsystem based on bcm2711_defconfig	
	fi
	yes "" | make oldconfig
	cd ${srcdir}/RPi4
	if [ ${GIT_HUB} != "https://github.com/" ];then
		for dir in . edk2 edk2-platforms edk2/CryptoPkg/Library/OpensslLib/openssl edk2/BaseTools/Source/C/BrotliCompress/brotli edk2/MdeModulePkg/Library/BrotliCustomDecompressLib/brotli
		do
			echo "Modifying ${dir}/.gitmodules"
			cd ${srcdir}/RPi4/${dir}/
			sed -i "s_https://github.com/_${GIT_HUB}_g; s_https://boringssl.googlesource.com_${GIT_HUB}/google_g" .gitmodules
			git submodule update --init
		done
    		# Apply modification to let submodules on github also use mirrorsite.
    	else
		git submodule update --init --recursive
	fi
	cd ${srcdir}/RPi4
	mkdir -p keys
	cp ${srcdir}/{ms_kek.cer,ms_db1.cer,ms_db2.cer,arm64_dbx.bin} keys/
	openssl req -new -x509 -newkey rsa:2048 -subj "/CN=Raspberry Pi Platform Key/" -keyout /dev/null -outform DER -out keys/pk.cer -days 7300 -nodes -sha256
	FIRMVER=$(git describe --tags).$(git rev-parse --short HEAD)
	cat>build_firmware.sh<<EOF
#!/usr/bin/env bash
export WORKSPACE=\$PWD
export PACKAGES_PATH=\$WORKSPACE/edk2:\$WORKSPACE/edk2-platforms:\$WORKSPACE/edk2-non-osi
export GCC5_AARCH64_PREFIX=${CROSS_COMPILE}
export BUILD_FLAGS="-D SECURE_BOOT_ENABLE=TRUE -D INCLUDE_TFTP_COMMAND=TRUE -D NETWORK_ISCSI_ENABLE=TRUE"
export DEFAULT_KEYS="-D DEFAULT_KEYS=TRUE -D PK_DEFAULT_FILE=\$WORKSPACE/keys/pk.cer -D KEK_DEFAULT_FILE1=\$WORKSPACE/keys/ms_kek.cer -D DB_DEFAULT_FILE1=\$WORKSPACE/keys/ms_db1.cer -D DB_DEFAULT_FILE2=\$WORKSPACE/keys/ms_db2.cer -D DBX_DEFAULT_FILE1=\$WORKSPACE/keys/arm64_dbx.bin"
source edk2/edksetup.sh
# EDK2's 'build' command doesn't play nice with spaces in environmnent variables, so we can't move the PCDs there...
build -a AARCH64 -t GCC5 -p edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc -b RELEASE --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor=L"https://github.com/pftf/RPi4" --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString=L"UEFI Firmware ${FIRMVER}" \${BUILD_FLAGS} \${DEFAULT_KEYS}

EOF
	chmod +x build_firmware.sh	
	patch --binary -d edk2 -p1 -i ../0001-MdeModulePkg-UefiBootManagerLib-Signal-ReadyToBoot-o.patch
	patch --binary -d edk2-platforms -p1 -i ../0002-Check-for-Boot-Discovery-Policy-change.patch
	# apply patch in repo as repo does this in CI service
}

build(){
	# Build UEFI Firware
	cd ${srcdir}/RPi4
	CHOST= CARCH= CPPFLAGS= CFLAGS= CXXFLAGS= LDFLAGS= make -C edk2/BaseTools
	# This tool needs to be compiled natively.
	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	bash build_firmware.sh || sudo bash build_firmware.sh
	# It may be failed to build on chroot environment with non-root user, use sudo to build it instead if failed.
	# Build Kernel
	cd ${srcdir}/linux
	make
}

package_raspberrypi4-uefi-firmware-git(){
	backup=("boot/config.txt")
	pkgdesc="UEFI firmware for ${_pkgdesc}"
	local file
	mkdir -p ${pkgdir}/boot/overlays
	install -Dm644 ${srcdir}/RPi4/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd ${pkgdir}/boot/
	install -Dm644 ${srcdir}/RPi4/config.txt ${pkgdir}/boot/config.txt
	if [ ${USE_GENERIC_KERNEL} == True ];then
		cp ${srcdir}/bcm2711-rpi-4-b.dtb ${pkgdir}/boot
	
		for file in miniuart-bt.dtbo disable-bt.dtbo
		do
			cp ${srcdir}/${file} ${pkgdir}/boot/overlays/
		done
	fi
	# Raspberry Pi Kernel have provided these files
	mkdir -p ${pkgdir}/boot/firmware
	cp -r ${srcdir}/RPi4/firmware/* ${pkgdir}/boot/firmware
    	install -Dm644 ${srcdir}/LICENCE.EDK2 "${pkgdir}"/usr/share/licenses/${pkgname}/LICENCE.EDK2
    	install -Dm644 ${srcdir}/LICENCE.broadcom "${pkgdir}"/usr/share/licenses/${pkgname}/LICENCE.broadcom
	
}

package_raspberrypi4-uefi-kernel-git(){
	pkgdesc="The Linux Kernel and modules for ${_pkgdesc}"
	depends=("coreutils" "linux-firmware" "kmod" "dracut" "firmware-raspberrypi" "raspberrypi4-uefi-firmware-git")
	optdepends=("crda: to set the correct wireless channels of your country")
	provides=("kernel26" "linux=$(echo ${pkgver} | cut -d "_" -f 1 | cut -d "." -f 1-3)")
	conflicts=("kernel26" "linux" "uboot-raspberrypi")
	backup=("boot/cmdline.txt")
	replaces=("linux-raspberrypi-latest")
    	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
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
		cp ${pkgdir}/boot/dtbs/broadcom/bcm271*-rpi-*.dtb ${pkgdir}/boot
		mkdir -p ${pkgdir}/boot/overlays
		cp ${pkgdir}/boot/dtbs/overlays/*.dtb* ${pkgdir}/boot/overlays/
		cp ${srcdir}/linux/arch/arm64/boot/dts/overlays/README ${pkgdir}/boot/overlays/
	fi
	cp .config ${pkgdir}/boot/config-${kernver}
	ln -s "../extramodules-${basekernel}-rpi4-uefi" "${pkgdir}/usr/lib/modules/${kernver}/extramodules"
	echo ${kernver} | install -Dm644 /dev/stdin ${pkgdir}/usr/lib/modules/extramodules-${basekernel}-rpi4-uefi/version
	rm ${pkgdir}/usr/lib/modules/${kernver}/{source,build}
	echo "root=LABEL=ROOT_MNJRO rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 usbhid.mousepoll=8 snd-bcm2835.enable_compat_alsa=0 audit=0" > ${pkgdir}/boot/cmdline.txt
	mkdir -p ${pkgdir}/usr/share/libalpm/scripts/
	cat>${pkgdir}/usr/share/libalpm/scripts/modify_grub_cmdline<<EOF
#!/usr/bin/sh
if [ -f /boot/cmdline.txt.pacsave ];then
	CMDFILE=/boot/cmdline.txt.pacsave
else
	CMDFILE=/boot/cmdline.txt
fi
CMDLINE="\$(sed 's/^root=.\+ rw //' \${CMDFILE})"
if [[ \${CMDLINE} != "" ]];then
	sed -i "s/^GRUB_CMDLINE_LINUX=\"\"$/GRUB_CMDLINE_LINUX=\"\${CMDLINE}\"/" /etc/default/grub
	echo "Finished modifying grub cmdline"
else
	echo "No need to modify grub cmdline because \${CMDFILE} is empty"
fi
EOF
	chmod +x ${pkgdir}/usr/share/libalpm/scripts/modify_grub_cmdline
	cp ${srcdir}/dracut-update-initramfs ${pkgdir}/usr/share/libalpm/scripts/
	chmod +x ${pkgdir}/usr/share/libalpm/scripts/dracut-update-initramfs
	mkdir -p ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/97-modify-grub-kernel-cmdline.hook ${pkgdir}/usr/share/libalpm/hooks/
	cp ${srcdir}/98-dracut-update-initramfs.hook ${pkgdir}/usr/share/libalpm/hooks/
}
package_raspberrypi4-uefi-kernel-headers-git(){
	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
        	export ARCH=arm64
        	export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/linux
	pkgdesc="Header files and scripts for building modules for linux kernel"
	provides=("linux-headers=$(echo ${pkgver} | cut -d "_" -f 1 | cut -d "." -f 1-3)")
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
package_raspberrypi4-uefi-kernel-api-headers-git(){
	if [ ${CARCH} != "aarch64" -o $(uname -m) != "aarch64" ];then
		export ARCH=arm64
		export CROSS_COMPILE=aarch64-linux-gnu-
	fi
	cd ${srcdir}/linux
	pkgdesc="Kernel headers sanitized for use in userspace"
	provides=("linux-api-headers=$(echo ${pkgver} | cut -d "_" -f 1 | cut -d "." -f 1-3)")
	conflicts=("linux-api-headers")
	make INSTALL_HDR_PATH="${pkgdir}/usr" headers_install
	# use headers from libdrm
	rm -r "${pkgdir}/usr/include/drm"
}

