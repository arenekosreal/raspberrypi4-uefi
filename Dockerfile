FROM archlinux/archlinux:base-devel
RUN pacman-key --init &&\
    pacman-key --populate archlinux &&\
    sed '1iServer = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch' -i /etc/pacman.d/mirrorlist &&\
    pacman -Sy &&\
    pacman -S git acpica python rsync bc xmlto docbook-xsl kmod inetutils --noconfirm --needed &&\
    rm -f /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew &&\
    rm -rf /etc/pacman.d/gnupg &&\
    useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    mkdir -p /home/builder/build_files &&\
    chown -R builder:builder /home/builder/build_files
USER builder
COPY start-build.sh /home/builder/start-build.sh
WORKDIR /home/builder/build_files
ENTRYPOINT [ "/usr/bin/bash", "/home/builder/start-build.sh" ]
