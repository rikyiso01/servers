set dotenv-load

install-bob:
    cd ./bob/nix/ && nixos-anywhere -- --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --target-host root@$BOB

update-bob:
    cd ./bob/nix/ && nixos-rebuild switch --use-remote-sudo --flake .#generic --target-host $BOB --build-host $BOB --verbose

update-bob-compose: sync-minecraft-plugins
    cd ./bob/docker/ && ROOT_DIR='~' DOCKER_HOST="ssh://$BOB" docker compose up --build --remove-orphans --detach
    cd ./bob/docker/ && DOCKER_HOST="ssh://$BOB" docker compose logs -f

bob-compose +args:
    cd ./bob/docker/ && DOCKER_HOST="ssh://$BOB" docker compose {{args}}

test-bob:
    nixos-anywhere -- --flake ./bob/nix#vm --vm-test

download-nixos:
    make -C ./images/ nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso
    cd ./images/ && sha256sum -c ./nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso.sha256

prepare-nixos-installer device: download-nixos
    sudo dd bs=4M if=./images/nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso of={{device}} conv=fsync oflag=direct status=progress
    sudo sync

download-minecraft-plugins:
    make -C ./bob/docker/minecraft/plugins/

sync-minecraft-plugins: download-minecraft-plugins
    ssh $BOB mkdir -p ~/minecraft/plugins/ ~/minecraft/plugins/
    rsync --recursive -m --include='*.jar' --exclude='*' --delete ./bob/docker/minecraft/plugins/ $BOB:~/minecraft/plugins/

