FROM lopsided/archlinux-arm64v8
RUN 	sed -i "s/PKGEXT='.pkg.tar.xz'/PKGEXT='.pkg.tar.zst'/; s/COMPRESSZST=(zstd -c -z -q -)/COMPRESSZST=(zstd -c -z -q - --threads=0)/" \
		/etc/makepkg.conf
	&& sed -i '2iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/\$arch/\$repo' /etc/pacman.d/mirrorlist \
	&& pacman -Syyu --noconfirm --needed \
	&& pacman -S base autoconf automake binutils bison fakeroot file findutils flex gawk \
		gcc gettext grep groff gzip libtool m4 make patch pkgconf texinfo which sudo git \
		acpica python rsync bc xmlto docbook-xsl kmod inetutils \
		--noconfirm --needed \
	&& rm -f /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew \
	&& useradd -m builder -d /home/builder \
	&& echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers 

