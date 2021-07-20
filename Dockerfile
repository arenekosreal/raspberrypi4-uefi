FROM archlinux/archlinux:base-devel
RUN pacman-key --init &&\
    pacman-key --populate archlinux &&\
    sed '1iServer = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch' -i /etc/pacman.d/mirrorlist &&\
    pacman -Syu --noconfirm &&\
    pacman -S glibc git acpica python rsync bc xmlto docbook-xsl kmod inetutils aarch64-linux-gnu-gcc --noconfirm --needed &&\
    rm -f /var/cache/pacman/pkg/* /var/lib/pacman/sync/* /etc/pacman.d/mirrorlist.pacnew &&\
    rm -rf /etc/pacman.d/gnupg &&\
    useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    mkdir -p /home/builder/build_files &&\
    chown -R builder:builder /home/builder/build_files
USER builder
COPY start-build.sh /home/builder/start-build.sh
WORKDIR /home/builder/build_files
# Use downgrade to downgrade gcc, or build may failed on gcc 11.1.0. Will remove this once edk2 updates its repo.
RUN git clone https://aur.archlinux.org/downgrade.git &&\
    cd downgrade &&\
    sudo pacman-key --init &&\
    sudo pacman-key --populate archlinux &&\
    sudo pacman -Syu --noconfirm &&\
    makepkg -si --noconfirm &&\
    cd .. &&\
    rm -rf downgrade &&\
    yes 1 | sudo downgrade --ala-only 'gcc==10.2.0-6' 'gcc-libs==10.2.0-6' -- --noconfirm
ENTRYPOINT [ "/usr/bin/bash", "/home/builder/start-build.sh" ]
