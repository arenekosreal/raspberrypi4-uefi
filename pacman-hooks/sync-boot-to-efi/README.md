# Sync required contents from /boot to /efi

Sync required contents to boot RaspberryPi 4B in UEFI mode from `/boot` to `/efi`

This should help people who mount ESP on `/efi`, but you can always adjust them to meet your needs.

## Usage

1. Disable hooks provided by `uefi-raspberrypi4` package

    You can run those commands to achive that:
    ```bash
    ln -s /dev/null /etc/pacman.d/hooks/70-post-install-uefi.hook
    ln -s /dev/null /etc/pacman.d/hooks/80-pre-remove-uefi.hook
    ```

2. Put [hooks](./hooks) and [scripts](./scripts) into `/etc/pacman.d`.

## FAQ

- Why not ship those in `uefi-raspberrypi4` package?

    Most people mount ESP on `/boot`, thus files required during boot have already been taken well care of.

