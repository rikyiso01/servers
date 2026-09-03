{ modulesPath
, lib
, pkgs
, self
, ...
}:
{
  imports = [
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  disko.devices.disk.main.device = "/dev/nvme0n1";
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
    timeoutStyle = "hidden";
    configurationLimit = 5;
  };

  swapDevices = [{
    device = "/nix/swapfile";
    size = 32 * 1024;
  }];

  time.timeZone = "Europe/Rome";

  fileSystems = {
    "/mnt/external" = {
      device = "/dev/mmcblk0p1";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  environment.persistence."/nix/persist" = {
    enable = true; # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/flatpak"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh_host_ed25519_key"
      "/etc/ssh_host_rsa_key"
    ];
  };


  networking.hostName = "deck";
  programs.uwsm.enable = true;
  programs.hyprland = {
    withUWSM = true;
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "riky";
      };
    };
  };

  services.flatpak.enable = true;

  services.udisks2.enable = true;

  services.upower.enable = true;

  networking.firewall = {
    enable = true;
  };

  networking.networkmanager.enable = true;

  services.getty.autologinUser = "riky";

  users.users = {
    riky = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRI8KdIpS8+g0IwxfzmrCBP4m7XWj0KECBz42WkgwsG rikyiso01"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        type = "ed25519";
        path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
      }
      {
        type = "rsa";
        bits = 4096;
        path = "/nix/persist/etc/ssh/ssh_host_rsa_key";
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

  powerManagement.powertop.enable = true;

  services.tlp = {
    enable = true;
  };

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
  nix.optimise = {
    automatic = true;
    dates = [ "03:00" ];
  };
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.05";
}
