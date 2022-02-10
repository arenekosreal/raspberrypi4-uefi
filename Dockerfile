FROM archlinux/archlinux:base-devel
RUN pacman-key --init &&\
    pacman-key --populate archlinux &&\
    sed '1iServer = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch' -i /etc/pacman.d/mirrorlist &&\
    pacman -Syu --noconfirm &&\
    pacman -S glibc git acpica python rsync bc xmlto docbook-xsl kmod inetutils aarch64-linux-gnu-gcc openssh bc libelf cpio perl tar xz gcc10 clang lld llvm --noconfirm --needed &&\
    rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/gnupg &&\
    useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    mkdir -p /home/builder/build_files &&\
    chown -R builder:builder /home/builder/build_files
USER builder
COPY start-build.sh /home/builder/start-build.sh
COPY makepkg-aarch64.conf /home/builder/makepkg-aarch64.conf
WORKDIR /home/builder/build_files
ENTRYPOINT [ "/usr/bin/bash", "/home/builder/start-build.sh" ]
