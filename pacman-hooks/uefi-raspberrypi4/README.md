# Sync required contents from /boot to EFI partition

Sync required contents to boot RaspberryPi 4B in UEFI mode from `/boot` to where EFI partition mounted

## Usage

1. Put [hooks](./hooks) and [scripts](./scripts) into `/etc/pacman.d`.

## FAQ

- Why not ship those in `uefi-raspberrypi4` package?

    Althouth it should work on EFI partition is mounted on `/efi`,`/boot` and `/boot/efi`, We think this should be tested more times.
    It will replace existing one in `uefi-raspberrypi4` when we think it is stable enough.

