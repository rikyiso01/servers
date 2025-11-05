{ modulesPath
, lib
, pkgs
, self
, ...
}:
{
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  swapDevices = [{
    device = "/persist/swapfile";
    size = 32 * 1024;
  }];

  environment.persistence."/persist" = {
    enable = true; # NB: Defaults to true, not needed
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/nix"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh_host_ed25519_key"
      "/etc/ssh_host_rsa_key"
    ];
  };



  networking.hostName = "pi4";


  networking.firewall = {
    enable = true;
  };

  users.users = {
    riky = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRI8KdIpS8+g0IwxfzmrCBP4m7XWj0KECBz42WkgwsG rikyiso01"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  programs.tmux.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        type = "ed25519";
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
      }
      {
        type = "rsa";
        bits = 4096;
        path = "/persist/etc/ssh/ssh_host_rsa_key";
      }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs.fuse.userAllowOther = true;

  virtualisation.docker.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  system.stateVersion = "24.05";
}
