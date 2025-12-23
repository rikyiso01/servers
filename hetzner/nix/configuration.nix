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
  disko.devices.disk.main.device = "/dev/sda";
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
    timeoutStyle = "hidden";
  };

  swapDevices = [{
    device = "/nix/swapfile";
    size = 4 * 1024;
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



  networking.hostName = "hetzner";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
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

  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "riky";

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  services.bind = {
    enable = true;
    zones = {
      "riccardoisola.dev" = {
        master = true;
        file = pkgs.writeText "zone-riccardoisola.dev" ''
          $ORIGIN riccardoisola.dev.
          $TTL    1h
          @            IN      SOA     ns1 hostmaster (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                       IN      NS      ns1
                       IN      NS      ns2

          @            IN      A       135.181.255.132
                       IN      AAAA    2a01:4f9:c013:d8e3::/64
                       IN      MX      10 mail
                       IN      TXT     "v=spf1 mx"

          www          IN      A       135.181.255.132
                       IN      AAAA    2a01:4f9:c013:d8e3::/64

          ns1          IN      A       135.181.255.132
                       IN      AAAA    2a01:4f9:c013:d8e3::/64

          ns2          IN      A       135.181.255.132
                       IN      AAAA    2a01:4f9:c013:d8e3::/64
        '';
      };
    };
  };

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
