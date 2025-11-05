set dotenv-load

mod bob "./bob/justfile"
mod deck "./deck/justfile"
mod pi4 "./pi4/justfile"
mod comet "./comet/justfile"

download-nixos:
    make -C ./images/ nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso
    cd ./images/ && sha256sum -c ./nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso.sha256

prepare-nixos-installer device: download-nixos
    sudo dd bs=4M if=./images/nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso of={{device}} conv=fsync oflag=direct status=progress
    sudo sync

download-nixos-sd:
    make -C ./images/ nixos-image-sd-card-25.05.810715.879bd460b3d3-aarch64-linux.img.zst
    cd ./images/ && sha256sum -c ./nixos-image-sd-card-25.05.810715.879bd460b3d3-aarch64-linux.img.zst.sha256

prepare-nixos-sd device: download-nixos-sd
    unzstd -c ./images/nixos-image-sd-card-25.05.810715.879bd460b3d3-aarch64-linux.img.zst | sudo dd bs=4M of={{device}} conv=fsync oflag=direct iflag=fullblock status=progress
    sudo mount --mkdir {{device}}p2 /mnt/nixos
    sudo mkdir -p /mnt/nixos/home/nixos/.ssh
    ssh-add -L | sudo tee /mnt/nixos/home/nixos/.ssh/authorized_keys
    sudo chown -R 1000:1000 /mnt/nixos/home/nixos/.ssh
    sudo umount /mnt/nixos
