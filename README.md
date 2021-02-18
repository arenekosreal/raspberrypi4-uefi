# Files for Booting Raspberry Pi in UEFI mode

![LICENCE.WTFPL](https://img.shields.io/github/license/zhanghua000/raspberrypi-uefi-boot?logoColor=9cf&style=flat-square "WTFPL LICENCE")
![Auto Build Arch Packages](https://github.com/zhanghua000/raspberrypi-uefi-boot/workflows/Auto%20Build%20Arch%20Packages/badge.svg)

## What is this?

Files needed for booting Raspberry Pi 4 in UEFI mode.  

## How to use?

`PKGBUILD` file is designed for Arch Build System (ABS), you can know more about it at [there](https://wiki.archlinux.org/index.php/Arch_Build_System). Here are the steps for using these files correctly:

- Clone this repository.  
- If you are using Arch Linux or other distributions based on it such as Manjaro, you can run `makepkg` command in the directory which contains PKGBUILD file, finally, you can find software packages generated by makepkg program. Install them and reboot your Pi, you can enjoy it.  
If you are not using Arch Linux, you may have to understand Arch Build System and do the same when the `makepkg` program is run at this directory.  
- How to build aarch64 package on x86_64 machine (both systems are Arch Based distributions and you should change working directory to this repository):  
    1. Install docker by run `sudo pacman -S docker`
    2. Install `qemu-user-static` in aur by run `yay -S qemu-user-static`
    3. Install `binfmt-manager` by install PKGBUILD file provided [there](https://github.com/mikkeloscar/packages/tree/master/binfmt-manager), run `binfmt_manager register` with sudo privilege. It will register qemu-emulator to your system and you can run aarch64 binary file directly on x86_64 platform. Also, you can run `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes` in terminal directly to register qemu-emulator. If you want to do it manually, you can skip this and go to step 4, then follow step 5
    4. This step is for people who want to install emulator manually. You need to run `echo ':aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7:\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff:/usr/bin/qemu-aarch64-static:' > /proc/sys/fs/binfmt_misc/register` with root privilege.
    5. Your kernel must have `BINFMT_MISC=y` in config, or qemu-user-static won't work. Setup docker buildx to build aarch64 image. You can find how to do it at docker's document([here](https://docs.docker.com/buildx/working-with-buildx/)). After you have built docker image with this repo, you can run this image directly, build process should start automatically. The only thing you should remember is that you need add argument `-v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v ${PWD}:/home/builder/build_files`. The complete command looks like this:`docker run --rm -v /usr/bin/qemu-user-static:/usr/qemu-user-static -v ${PWD}:/home/builder/build_files`

## NOTE

1. Backup your Pi's files or at least backup boot partition. Or you may have to reinstall your original system.  
2. UEFI firmware is experimental, that means maybe some features may not work properly. You can get more infomation at [there](https://github.com/pftf/RPi4)  
3. Install grub with `--removeable` flag, or you have to choose boot from `/EFI/grub/grubaa64.efi` file in UEFI manually when your Pi is powering on.
4. This project is designed for `aarch64`(arm64) architecture, it is just for test so you can compile on `x86_64` machine with `aarch64-linux-gnu-gcc` toolchain. Due to my ability, if you compiled on a `x86_64` computer, the software package will be treat as `x86_64` package and you can't install it directly on your Pi although all binary files in this package is designed for running on `aarch64` machine. So I recommend you to compile this package directly on your Pi and install it or manually copy generated files to your filesystem.  

## References

UEFI provided by [this](https://github.com/pftf/RPi4) project. Thanks to [pftf](https://github.com/pftf) and others' contribution, we can use UEFI Firmware in RaspberryPi.  
Kernel provided by RaspberryPi Foundation at [this](https://github.com/raspberrypi/linux) project.
