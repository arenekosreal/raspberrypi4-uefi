FROM archlinux/archlinux:base-devel
RUN pacman-key --init &&\
    pacman-key --populate archlinux &&\
    pacman -Syu --noconfirm &&\
    pacman -S glibc git acpica python rsync bc xmlto docbook-xsl kmod inetutils aarch64-linux-gnu-gcc openssh bc libelf cpio perl tar xz clang lld llvm --noconfirm --needed &&\
    pacman -U https://archive.archlinux.org/packages/g/gcc10/gcc10-1%3A10.3.0-2-x86_64.pkg.tar.zst https://archive.archlinux.org/packages/g/gcc10-libs/gcc10-libs-1%3A10.3.0-2-x86_64.pkg.tar.zst --noconfirm &&\
    rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/gnupg &&\
    useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    mkdir -p /home/builder/build_files &&\
    chown -R builder:builder /home/builder/build_files &&\
    chown root:root /usr/bin &&\
    chmod u+s /usr/bin/sudo
USER builder
COPY start-build.sh /home/builder/start-build.sh
COPY makepkg-aarch64.conf /home/builder/makepkg-aarch64.conf
WORKDIR /home/builder/build_files
ENTRYPOINT [ "/usr/bin/bash", "/home/builder/start-build.sh" ]
