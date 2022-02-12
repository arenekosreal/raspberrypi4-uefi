# Files for Booting Raspberry Pi in UEFI mode

![LICENCE.WTFPL](https://img.shields.io/github/license/zhanghua000/raspberrypi-uefi-boot?logoColor=9cf&style=flat-square "WTFPL LICENCE")
![Auto Build Arch Packages](https://github.com/zhanghua000/raspberrypi-uefi-boot/workflows/Auto%20Build%20Arch%20Packages/badge.svg)

## What is this?

Files needed for booting Raspberry Pi 4 in UEFI mode.  

## How to use?

`PKGBUILD` file is designed for Arch Build System (ABS), you can know more about it at [there](https://wiki.archlinux.org/index.php/Arch_Build_System). Here are the steps for using these files correctly:

- Clone this repository.  
- If you are using Arch Linux or other distributions based on it such as Manjaro, you can run `bash start-build.sh` command in the root directory of this repo after installed requirements (see [Dockerfile](./Dockerfile) for more info), finally, you can find software packages generated by makepkg program at `out` folder. Install them, configure grub and reboot your Pi, you can enjoy it. Note: choose which kernel you want (generic or raspberrpi), you can't use both kernel because they are conflict in their depends.  
If you are not using Arch Linux, you may have to understand Arch Build System and do the same when the `makepkg` program is run. Or use docker, see [CI config](./.github/workflows/build-packages.yml) for more info. CI is running on Ubuntu x86_64 host and you can use it as a reference. Note: final artifacts in `out` folder is Arch Linux Package, if you want to create package for your distribution, you shouldn't use docker and you should turn to read `makepkg` files.   

## Why not upload to AUR or Arch Linux ARM repository?

~~UEFI firmware needs root privilege to build on my Arch Distribution. So I think it can't be treated as a valid PKGBUILD because a valid one needs no manual interaction.~~ This problem has been fixed.  
UEFI firmware needs `gcc10` to build, which is not provided on Arch Linux ARM. This problem will only be solved when edk2 upgrade `BrotilCompress` to newer version which supports GCC 11 or Arch Linux ARM provides `gcc10` package.  
Also, both kernels are stripped because some devices I may never use, this also results that these kernels are not suitable for everyone's use. You can change kernel config as you like, just remember one thing: DO NOT disable UEFI and ACPI related configs.  
As for other aspects, there should be no issue to upload, I have even set `buildarch` to meet Arch Linux ARM's requirements.  
If you think pacman or other wrapper complains about not found these packages, please add them to `IgnorePkg` in `/etc/pacman.conf`

## About Native compile

Native compile doesn't need cross-compile toolchains, but it needs you setup an aarch64 chroot environment. You can check build script for more info. It is used for testing if package can be built on RaspberryPi successfully.  
Also, due to that Arch Linux ARM doesn't provide `gcc10` package, native compile is not available now, but you can test it on non-UEFI packages because they don't need `gcc10` to build.

## NOTE

1. Backup your Pi's files or at least backup boot partition. Or you may have to reinstall your original system.  
2. UEFI firmware is experimental, that means maybe some features may not work properly. You can get more infomation at [there](https://github.com/pftf/RPi4)  
3. Install grub with `--removeable` flag, or you have to choose boot from `/EFI/grub/grubaa64.efi` file in UEFI manually when your Pi is powering on. Also you can add a boot entry in UEFI manualy to solve this.

## References

UEFI provided by [this](https://github.com/pftf/RPi4) project. Thanks to [pftf](https://github.com/pftf) and others' contribution, we can use UEFI Firmware in RaspberryPi.  
Kernel provided by RaspberryPi Foundation at [this](https://github.com/raspberrypi/linux) project, generic kernel is provided by torvalds at [this](https://github.com/torvalds/linux).
