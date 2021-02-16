#!/usr/bin/env bash
sudo chown -R builder:builder /home/builder/build_files
makepkg -fdC
