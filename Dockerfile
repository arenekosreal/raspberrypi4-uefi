FROM lopsided/archlinux-arm64v8
COPY PKGBUILD /home/travis/PKGBUILD
COPY *.hook /home/travis/
COPY *.patch /home/travis/
RUN 	sed -i '2iServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/\$arch/\$repo' /etc/pacman.d/mirrorlist \
	&& pacman -Syyu --noconfirm --needed \
	&& pacman -S base autoconf automake binutils bison fakeroot file findutils flex gawk \
		gcc gettext grep groff gzip libtool m4 make patch pkgconf texinfo which sudo git \
		acpica python rsync bc xmlto docbook-xsl kmod inetutils --noconfirm --needed \
	&& rm -f /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew \
	&& useradd -m travis -d /home/travis \
	&& chown -R travis:travis /home/travis/ \
	&& echo 'travis ALL=(ALL) ALL' >> /etc/sudoers \
	&& su -l travis -c 'cd && makepkg -d' 
