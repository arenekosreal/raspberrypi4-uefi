#!/usr/bin/env bash
cd build_files
sudo chown -R builder:builder .
makepkg -fC --syncdeps --noconfirm
