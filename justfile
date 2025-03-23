set dotenv-load

install-bob:
    cd ./bob/nix/ && nixos-anywhere -- --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --target-host root@$BOB

update-bob:
    cd ./bob/nix/ && nixos-rebuild switch --use-remote-sudo --flake .#generic --target-host $BOB --build-host $BOB --verbose

# update-bob-compose: sync-minecraft-plugins
update-bob-compose:
    ssh $BOB mkdir -p ~/minecraft/data
    ROOT_DIR='~' DOCKER_HOST="ssh://$BOB" docker compose --file ./bob/docker/docker-compose.yml up --build --remove-orphans --detach
    DOCKER_HOST="ssh://$BOB" docker compose --file ./bob/docker/docker-compose.yml logs -f

bob-minecraft-console *args:
    DOCKER_HOST="ssh://$BOB" docker compose --file ./bob/docker/docker-compose.yml exec minecraft rcon-cli {{args}}

bob-compose *args:
    cd ./bob/docker/ && DOCKER_HOST="ssh://$BOB" docker compose {{args}}

test-bob-installation:
    nixos-anywhere -- --flake ./bob/nix#vm --vm-test

download-nixos:
    make -C ./images/ nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso
    cd ./images/ && sha256sum -c ./nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso.sha256

prepare-nixos-installer device: download-nixos
    sudo dd bs=4M if=./images/nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso of={{device}} conv=fsync oflag=direct status=progress
    sudo sync

test-bob-minecraft:
    docker compose --file ./bob/docker/docker-compose.yml up --build --remove-orphans --detach minecraft
    docker compose --file ./bob/docker/docker-compose.yml logs -f minecraft

test-bob-minecraft-console *args:
    docker compose --file ./bob/docker/docker-compose.yml exec minecraft rcon-cli {{args}}

