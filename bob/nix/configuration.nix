{ modulesPath
, lib
, pkgs
, ...
}:
{
  imports = [
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  disko.devices.disk.main.device = "/dev/sda";
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };


  networking.hostName = "bob";

  users.users = {
    riky = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRI8KdIpS8+g0IwxfzmrCBP4m7XWj0KECBz42WkgwsG rikyiso01"
      ];
      extraGroups = [ "wheel" "docker" ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.logind.lidSwitch = "ignore";

  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable=true;

  system.stateVersion = "24.05";
}
