#!/usr/bin/env bash

set -euo pipefail

udisksctl unmount -b /dev/sda1 || true
udisksctl mount -b /dev/sda1

mprocs "bash $HOME/backup/Documents/nix/update.sh" "bash $HOME/backup/Documents/config/backup/backup.sh" "bash $HOME/backup/Documents/Projects/nix/servers/update.sh"

udisksctl mount -b /dev/sda1 || true
