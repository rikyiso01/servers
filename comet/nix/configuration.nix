{ modulesPath
, lib
, pkgs
, self
, ...
}:
{
  imports = [
    ./disk-config.nix
  ];
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  disko.devices.disk.main.device = "/dev/nvme0n1";
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
    timeoutStyle = "hidden";
  };

  swapDevices = [{
    device = "/nix/swapfile";
    size = 32 * 1024;
  }];

  environment.persistence."/nix/persist" = {
    enable = true; # NB: Defaults to true, not needed
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/docker"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh_host_ed25519_key"
      "/etc/ssh_host_rsa_key"
    ];
  };



  networking = {
    hostName = "comet";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 5353 ];
    };
    useDHCP = false;
    wireless = {
      enable = true;
      secretsFile = "/nix/persist/wireless_secrets";
      networks = {
        "Island wifi" = {
          pskRaw = "ext:psk_home";
          priority = 2;
        };
        "Island wifi 2.4" = {
          pskRaw = "ext:psk_home_24";
          priority = 1;
        };
      };
    };
    interfaces.enp2s0.ipv4.addresses = [{
      address = "192.168.0.34";
      prefixLength = 24;
    }];
    interfaces.wlp1s0.ipv4.addresses = [{
      address = "192.168.0.33";
      prefixLength = 24;
    }];
    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlp1s0";
    };
    nameservers = [ "8.8.8.8" ];
  };

  users.users = {
    riky = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRI8KdIpS8+g0IwxfzmrCBP4m7XWj0KECBz42WkgwsG rikyiso01"
      ];
      extraGroups = [ "wheel" "docker" ];
    };
  };

  programs.tmux.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      MaxStartups = "50:30:100";
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

  services.udisks2.enable = true;

  services.printing = {
    enable = true;
    openFirewall = true;
    defaultShared = true;
    browsing = true;
    listenAddresses = [
      "*:631"
    ];
    allowFrom = [
      "all"
    ];
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_Smart_Tank_Plus_550_series_FE3564_USB";
        model = "everywhere";
        # driverless command
        deviceUri = "ipp://HP%20Smart%20Tank%20Plus%20550%20series%20%5BFE3564%5D%20(USB)._ipp._tcp.local/";
        description = "HP_Smart_Tank_Plus_550_series_FE3564_USB";
      }
    ];
  };

  services.ipp-usb.enable = true;


  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "riky";

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--filter=label!=keep" ];
    };
  };

  time.timeZone = "Europe/Rome";

  nix.extraOptions = ''experimental-features = nix-command flakes'';

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
    allowReboot = true;
  };

  system.stateVersion = "24.05";
}
