# Files for Booting Raspberry Pi in UEFI mode

![LICENCE.WTFPL](https://img.shields.io/github/license/zhanghua000/raspberrypi-uefi-boot?logoColor=9cf&style=flat-square "WTFPL LICENCE")
![Auto Build Arch Packages](https://github.com/zhanghua000/raspberrypi-uefi-boot/workflows/Auto%20Build%20Arch%20Packages/badge.svg)

## What is this?

Files needed for booting Raspberry Pi 4 in UEFI mode.  

## How to use?

`PKGBUILD` file is designed for Arch Build System (ABS), you can know more about it at [there](https://wiki.archlinux.org/index.php/Arch_Build_System). Here are the steps for using these files correctly:

- Clone this repository.
- [Build](#build) packages.
- [Install](#install) package by using `pacman -U`
- [Adjust bootloader](#adjust-bootloader)

## Build

We are using GitHub Action completely to build those packages now. It has those benifits:

1. No need to set dependencies manually, we just use GitHub Action's `needs` key to define that. This will build all packages as many as possible.

2. No need to maintain two build workflows. If build workflow passes on GitHub Action, it will pass locally.

3. You can build those packages on non-archlinuxarm distributions, like ubuntu.

Howewer, this means that you may not build packages as easy as old days. But we still provide a simple guide here:

1. Install [act](https://github.com/nektos/act), which is the magic to let GitHub Action run locally.

2. Simply run `act` and everything should be fine. If everything works correctly, you will find packages at `./act/out` directory in the repository.

> [!NOTE]
> You can always build packages on archlinuxarm by running commands like `makepkg` `makechrootpkg` in the `PKGBUILD` directory.
> Using act can allow building packages on non-archlinuxarm distributions. But built packages are still only available to archlinuxarm.

> [!TIP]
> If sometimes there is a network error to mirror.archlinuxarm.org, you can simply retry after a cup of cola.

> [!IMPORTANT]
> If you use qemu-user-static to emulate aarch64 on x86_64, you have to ensure `C` in its flags. Or you will fail to install dependencies.

## Install

Most of the time you need to install packages provide `uefi-raspberrypi4` and `raspberrypi-overlays`.
If you want to install dependencies used for building, you can install `raspberrypi4-uefi-devel-meta` meta package.
Here are also some pacman hooks maybe useful for you at [pacman-hooks](./pacman-hooks) folder, you can check `README.md` here for how to use them.

## Adjust bootloader

You can choose any bootloader supports UEFI, like `grub` or `systemd-boot`.
You may also need to migrate your kernel parameters, they used to be staying in `/boot/cmdline.txt`, you may consider using your bootloader's configuration instead.
You can take a look at [NOTE](#note) for more info.

## Why not upload to AUR or Arch Linux ARM repository?
They are [here](https://github.com/archlinuxarm/PKGBUILDs/pull/1958), but this PR has not been merged.
If you think pacman or other wrapper complains about not found these packages, please add them to `IgnorePkg` in `/etc/pacman.conf`

## NOTE

1. Backup your Pi's files or at least backup boot partition. Or you may have to reinstall your original system.  
2. UEFI firmware is experimental, that means maybe some features may not work properly. You can get more infomation at [there](https://github.com/pftf/RPi4)  
3. Install grub with `--removeable` flag, or you have to choose boot from `/EFI/grub/grubaa64.efi` file in UEFI manually when your Pi is powering on. Also you can add a boot entry in UEFI manualy to solve this. For systemd-boot, `--no-variables` should be OK.
4. According to kernel [documentation](https://www.kernel.org/doc/Documentation/arm64/booting.rst), a compressed aarch64 kernel does not have a decompressor, so you have to choose a bootloader which can do the decompression job. GRUB works well on Raspberry Pi 4B even with the compressed vmlinuz kernel.  
5. GRUB may create some useless entries in advanced menu, like booting from vmlinux without initramfs, booting from Image without initramfs and so on, you can remove them as you like, booting from vmlinuz with initramfs works well.  

## References

UEFI provided by [this](https://github.com/pftf/RPi4) project. Thanks to [pftf](https://github.com/pftf) and others' contribution, we can use UEFI Firmware in RaspberryPi.  
Overlays provided by [raspberrypi/firmware](https://github.com/raspberrypi/firmware).
